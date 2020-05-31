#!/bin/bash

function error() {
	echo -e "\\033[31m>> $@\\033[39m";
    exit 1
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

# sha256 <path_to_file>
function sha256() {
    openssl dgst -sha256 $1 | awk '{print $NF}'
}

# sha256 <url> <sha256> [local]
function download() {
    local url=$1
    local sha=$2
    local file=$3
    local exists=0

    info "$url $sha => $file"

    if [ -e $file ]; then
        if [[ `sha256 $file` == $sha ]]; then 
            info "local file exists"
            exists=1
        else
            error "$file broken..."
            rm $file
        fi
    fi

    if [ $exists -eq 0 ]; then
        which wget > /dev/null
        if [ $? -eq 0 ]; then 
            wget $url -O $file
        else 
            which curl > /dev/null
            if [ $? -eq 0 ]; then
                curl $url --output $file
            else
                error "missing wget and curl"
                break;
            fi
        fi
    fi
}

# extract <file> [options]
function extract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar xvjf $* 	;;
            *.tar.gz) 	tar xvzf $* 	;;
            *.tar.xz)   tar xvfJ $*     ;;
            *.bz2) 		bunzip2 $* 	    ;;
            *.rar) 		unrar x $* 	    ;;
            *.gz) 		gunzip $* 	    ;;
            *.tar) 		tar xvf $* 	    ;;
            *.tbz2) 	tar xvjf $* 	;;
            *.tgz) 		tar xvzf $* 	;;
            *.zip) 		unzip $* 	    ;;
            *.Z) 		uncompress $* 	;;
            *.7z) 		7z x $* 	    ;;
            *) 	        error "don't knwon how to extract '$1' ..." ;;
        esac
    else
        echo "'$1' doesn't exist ..."
    fi
}

# prepare_pkg_source <url> <sha256> <local>
function prepare_pkg_source () {
    echo $@
    download $@ || error "download $@ failed"
    #tmp=`mktemp -d` || error "$0 $@ create temp dir failed"
    #cd $tmp
    extract $3 > /dev/null || error "extract $3 failed"
}

