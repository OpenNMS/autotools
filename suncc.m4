AC_DEFUN([ONMS_CHECK_SUNCC],
  [
    AC_MSG_CHECKING([if $CC is Sun CC])
    
    if $CC -V 2>&1 | grep '^cc: Sun C' > /dev/null; then
        HAS_SUNCC="yes"
    else
        HAS_SUNCC="no"
    fi

    AC_MSG_RESULT([$HAS_SUNCC])
  ]
)
