#!/bin/bash

FILE_IMAGES_LIST=/Projects/XNImagetTransfer/images.list

while read line
do
    image=$(echo $line | awk '{print $1}')
    newImage=$(echo $line | awk '{print $2}')
    /usr/local/bin/docker pull $image
    if [ $? -eq 0 ]
    then
        name=`echo $image | cut -d \: -f 1`
        version=`echo $image | cut -d \: -f 2`
        echo $name $version
        line=`/usr/local/bin/docker images | grep -e "$name.*$version"`
        if [ $? -eq 0 ]
        then
            cid=$(echo $line | awk '{print $3}')
            if [ $? -eq 0 ]
            then
                echo "containerId=$cid"
                /usr/local/bin/docker tag $cid $newImage
                if [ $? -eq 0 ]
                then
                    /usr/local/bin/docker push $newImage
                    if [ $? -eq 0 ]
                    then
                        echo 'docker push success'
                    else
                        echo "docker push fail $?"
                    fi
                else
                    echo "docker tag fail $?"
                fi
            else
                echo "fetch cid fail $?"
            fi
        else
            echo "fetch image line fail $?"
        fi
    else
        echo "docker pull fail $?"
    fi
done <$FILE_IMAGES_LIST
