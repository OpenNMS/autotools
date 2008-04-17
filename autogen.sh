#!/bin/sh

[ -z "$ACLOCAL"    ] && ACLOCAL=aclocal
[ -z "$AUTOHEADER" ] && AUTOHEADER=autoheader
[ -z "$LIBTOOLIZE" ] && LIBTOOLIZE=glibtoolize
[ -z "$AUTOCONF"   ] && AUTOCONF=autoconf
[ -z "$AUTOMAKE"   ] && AUTOMAKE=automake
[ -z "$AUTORECONF" ] && AUTORECONF=autoreconf

[ -x "`which libtoolize 2>/dev/null`" ] && LIBTOOLIZE=libtoolize

$AUTOHEADER --force
$LIBTOOLIZE --automake --copy --force
$ACLOCAL --force -I m4
$AUTOMAKE --add-missing --copy
$AUTOCONF --force
