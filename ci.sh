#!/bin/bash

usage() {
	echo "usage: $0 <bittedness> <SVN revision> <build number>"
	echo ""
}

die() {
	usage
	echo "failed: $@"
	exit 1
}

BITS="$1"; shift
REVISION="$1"; shift
BUILDNUM="$1"; shift

[ -n "$BITS"     ] || die "you must specify bittedness"
[ -n "$REVISION" ] || die "you must specify the SVN revision"
[ -n "$BUILDNUM" ] || die "you must specify the build number"

RPM_ARGS=""
HOST_ARGS=""

OS=`uname -s | tr 'A-Z' 'a-z'`
MACHINE=`uname -m`

if [ "$OS" = "linux" ]; then
	if [ "$BITS" = "64" ]; then
		RPM_ARGS="--with-rpm-extra-args=--target x86_64"
		HOST_ARGS="--host=x86_64-$OS"
	else
		RPM_ARGS="--with-rpm-extra-args=--target $MACHINE"
		HOST_ARGS="--host=$MACHINE-$OS"
	fi
fi

sh m4/autogen.sh
./configure --prefix=/usr --with-java="${JAVA_HOME}" --with-jvm-arch=$BITS "$RPM_ARGS" "$HOST_ARGS"
if [ -x /bin/rpm ]; then
	make rpm RELEASE="0.${REVISION}.${BUILDNUM}"
else
	make
fi
make install DESTDIR=`pwd`/dist
