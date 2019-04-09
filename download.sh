#!/bin/bash 
SOURCE=`dirname $0`
source $SOURCE/cbox.sh 

function sha256() {
    openssl dgst -sha256 $1 | awk '{print $NF}'
}

cat $SOURCE/list.txt | while read line; do
    sha=`echo $line | awk '{print $1}'`
    url=`echo $line | awk '{print $2}'`
    file=`basename $url`
    info $url " => " $sha

    exists=0
    if [ -e packages/$file ]; then
        info "$file exists..."
        # test sha
        if [ "`sha256 packages/$file`" = "$sha" ]; then
            exists=1
        else
            error "$file broken..."
            rm packages/$file
        fi
    fi

    if [ $exists -eq 0 ]; then
        info "$file download from $url"
        which wget > /dev/null
        if [ $? -eq 0 ]; then 
            wget $url -O packages/$file
        else 
            which curl > /dev/null
            if [ $? -eq 0 ]; then
                curl $url --output packages/$file
            else
                error "missing wget and curl"
                break;
            fi
        fi

        if [ `sha256 packages/$file` != $sha ]; then
            error "$file download broken file"
        fi
    fi
done
