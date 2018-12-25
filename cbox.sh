#!/bin/bash

function error() {
	echo -e "\\033[31m>> $@\\033[39m";
	return 0;
}

function info() {
	echo -e "\\033[32m>> $@\\033[39m";
	return 0;
}

function warning() {
	echo -e "\\033[33m>> $@\\033[39m";
	return 0;
}

function sel() {
	echo -en "\\033[33m== $1 ";
	if [ $2 = 0 ]; then
		echo -en "[Y/n]\\033[39m"
		read ans
		ans=`echo $ans | tr A-Z a-z`
		if test "$ans" = "y" -o "$ans" = ""; then
			return 0;
		fi
	else
		echo -en "[y/N]\\033[39m"
		read ans
		ans=`echo $ans | tr A-Z a-z`
		if test "$ans" = "n" -o "$ans" = ""; then
			return 0;
		fi
	fi
	return 1;
}

function pause() {
    echo -en "\\033[31m== $1 ";
    read ans;
    echo -en "\\033[39m"
    return 0;
}

function myfind() {
    find $@ ! -path '*/.*' -type f
}

function cfind() {
    find $1 ! -path '*/.*' -type f -name *.c -o -name *.h -name *.cpp
}

case `basename $0` in
    "myfind")
        info "myfind $@"
        myfind $@
        ;;
    "cfind")
        info "cfind $1"
        cfind $1;
        ;;
    "cpd")
        ;;
    *)
        ;;
esac
