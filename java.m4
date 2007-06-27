AC_DEFUN([ONMS_CHECK_JDK],
  [
    dnl look for java in various places
    dnl first check where the told me
    dnl if the didn't tell me look in JAVA_HOME
    dnl then look in the Mac Location
    dnl then look in /etc/alternatives or whatever
    dnl then look in /usr/java/default
    dnl then look in /usr/java/*
    dnl then look in /usr/local/java
    dnl other places?
    dnl need to verify its the correct version (or later)
    dnl need to verify that it has javah
    dnl need to verify that it has javac
    dnl need to verify that it has jni headers 

    AC_ARG_WITH([java],
      [AS_HELP_STRING([--with-java=JAVA_HOME], [set the path to JAVA_HOME for the jdk])],
      [],
      [with_java=check])

    AS_IF([test "x$with_java" = "xno"], [AC_MSG_ERROR([the path to a jdk is required to build jrrd])])
    AS_IF([test "x$with_java" = "xyes"], [AC_MSG_ERROR([the argument to --with-java must specify a JDK])])
    AS_IF([test "x$with_java" = "xcheck"], 
          [ONMS_FIND_JDK($1)],
          [ONMS_VALIDATE_JDK(["$with_java"], $1)]
    )

    AS_IF([test "x$HAS_JDK" = "x" || test "$HAS_JDK" = "false" || test "$HAS_JDK" = "no"],
          [AC_MSG_ERROR([unable to find a valid jdk])])

    AC_MSG_NOTICE([using jdk at $JAVA_HOME])

    AC_SUBST([JAVA_HOME])
    AC_SUBST([JAVA])
    AC_SUBST([JAR])
    AC_SUBST([JAVAC])
    AC_SUBST([JAVAH])
    AC_SUBST([JNI_INCLUDES])
    AC_SUBST([JNI_LIB_EXTENSION])
  ]
)

AC_DEFUN([ONMS_FIND_JDK],
  [
    AC_MSG_NOTICE([searching for a $1 jdk])
    
    HAS_JDK=no
    AS_IF([test "x$JAVA_HOME" != "x"], 
      [_ONMS_TRY_JAVA_DIR([$JAVA_HOME], [$1], [AC_MSG_NOTICE([trying the value in JAVA_HOME])])]
    )

    _ONMS_TRY_JAVA_DIR([/Library/Java/Home], [$1])
    _ONMS_TRY_JAVA_DIR([/usr/java/default], [$1])
    
  ]
)

AC_DEFUN([_ONMS_TRY_JAVA_DIR],
  [
    AS_IF([test "$HAS_JDK" = no && test -d "$1"], 
      [
        $3
        ONMS_VALIDATE_JDK([$1], [$2])
      ]
    )
  ]
)

AC_DEFUN([ONMS_VALIDATE_JDK],
  [
    AC_MSG_NOTICE([checking if $1 is home for a valid $2 jdk])

    HAS_JDK=yes
    dnl the following so HAS_JDK of they fail to pass the check
    _ONMS_CHECK_FOR_JAVA($1)
    _ONMS_CHECK_FOR_JAVAC($1)
    _ONMS_CHECK_FOR_JAR($1)   
    _ONMS_CHECK_FOR_JAVAH($1)
    _ONMS_CHECK_JAVA_VERSION($2)

    AS_IF([test "$HAS_JDK" != yes], 
          [AC_MSG_NOTICE([no valid jdk found at $1])],
          [AC_MSG_NOTICE([found a valid jdk. setting JAVA_HOME to $1]); JAVA_HOME="$1"]
    )

  ]
)

AC_DEFUN([_ONMS_CHECK_JAVA_VERSION],
  [
    AS_IF([test "$HAS_JDK" = yes],
      [
        HAS_VALID_JAVA_VERSION=yes
        AC_MSG_CHECKING([if java version meets requirements for $1])
        _ONMS_CREATE_GETVER_SRC([getver])
        _ONMS_COMPILE_SOURCE_FILE([getver.java], [tmp-classes], [])
        _JAVA_VERSION=`$JAVA -cp tmp-classes getver`
        rm -rf tmp-classes
        rm -f getver.java

        AS_IF([test "x$_JAVA_VERSION" = "x" || expr "$_JAVA_VERSION" \< "$1" > /dev/null],
          [
            HAS_VALID_JAVA_VERSION=no
            HAS_JDK=no
          ]
        )
        AC_MSG_RESULT([$HAS_VALID_JAVA_VERSION version is $_JAVA_VERSION])
      ]
    )
  ]
)

AC_DEFUN([_ONMS_COMPILE_SOURCE_FILE],
  [
    _JVC_FLAGS=
    AS_IF([test "x$2" != "x"],
      [
        AS_IF([test ! -d "$2"], [mkdir -p "$2"])
        _JVC_FLAGS="-d $2"
      ]
    )
    AS_IF([test "x$3" != "x"],
      [
        _JVC_FLAGS="$_JVC_FLAGS -cp $3"
      ]
    )

    $JAVAC $_JVC_FLAGS "$1"

    AS_UNSET([_JVC_FLAGS])
  ]
)

AC_DEFUN([_ONMS_CREATE_GETVER_SRC],
  [
    cat > $1.java <<EOF
class $1 {
  public static void main(String args@<:@@:>@) {
    System.out.println(System.getProperty("java.specification.version"));
  }
}
EOF
  ]
)

AC_DEFUN([_ONMS_CHECK_FOR_JAVA], [_ONMS_CHECK_FOR_JAVA_PROG($1, [java])])
AC_DEFUN([_ONMS_CHECK_FOR_JAR], [_ONMS_CHECK_FOR_JAVA_PROG($1, [jar])])
AC_DEFUN([_ONMS_CHECK_FOR_JAVAC], [_ONMS_CHECK_FOR_JAVA_PROG($1, [javac])])
AC_DEFUN([_ONMS_CHECK_FOR_JAVAH], [_ONMS_CHECK_FOR_JAVA_PROG($1, [javah])])

AC_DEFUN([_ONMS_CHECK_FOR_JAVA_PROG],
  [
    AS_IF([test "$HAS_JDK" = yes],
      [
        HAS_VAR($2)=no
        AC_MSG_CHECKING([if $1 has $2])
        AS_IF([test -x "$1/bin/$2"], [HAS_VAR($2)=yes])
        AC_MSG_RESULT([$HAS_VAR($2)])
        m4_toupper($2)="$1/bin/$2"
        AS_IF([test "$HAS_VAR($2)" = no], [HAS_JDK=no])
      ]
    )
  ]
)

AC_DEFUN([HAS_VAR], [HAS_@&t@m4_toupper($1)])
    

