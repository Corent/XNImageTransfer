#!/bin/bash

FILE_IMAGES_LIST=/Projects/XNImagetTransfer/images.list.2.3
TAR_PATH=/home/dxrd/images/

while read line
do
    host=$(echo $line | awk '{print $1}')
    image=$(echo $line | awk '{print $2}')
    echo "docker pull $host/$image"
    /usr/bin/docker pull $host/$image
    if [ $? -eq 0 ]
    then
        name=`echo $image | cut -d \: -f 1`
        version=`echo $image | cut -d \: -f 2`
        echo $name $version
        line=`/usr/bin/docker images | grep -e "$host/$name.*$version"`
        if [ $? -eq 0 ]
        then
            iid=$(echo $line | awk '{print $3}')
            if [ $? -eq 0 ]
            then
                echo "imageId=$iid"
                /usr/bin/docker save $iid> $TAR_PATH$image.tar
                if [ $? -eq 0 ]
                then
                    sz $TAR_PATH$image.tar
                    if [ $? -eq 0 ]
                    then
                        echo "sz $TAR_PATH$image.tar success"
                    else
                        echo "sz $TAR_PATH$image.tar fail $?"
                    fi
                else
                    echo "docker save fail $?"
                fi
            else
                echo "fetch iid fail $?"
            fi
        else
            echo "fetch image line fail $?"
        fi
    else
        echo "docker pull fail $?"
    fi
done <$FILE_IMAGES_LIST
