#!/bin/bash

prefix=2.8.0.1:8001/infra/
images=(google/cadvisor:v0.25.0 google/cadvisor:v0.25.0)

for image in ${images[@]}
do
    name=`echo $image | cut -d \: -f 1`
    version=`echo $image | cut -d \: -f 2`
    /usr/local/bin/docker pull $image
    if [ $? -eq 0 ]
    then
        echo $name $version
        line=`/usr/local/bin/docker images | grep -e "$name.*$version"`
        if [ $? -eq 0 ]
        then
            cid=$(echo $line | awk '{print $3}')
            if [ $? -eq 0 ]
            then
                echo "containerId=$cid"
                /usr/local/bin/docker tag $cid $prefix$image
                if [ $? -eq 0 ]
                then
                    /usr/local/bin/docker push $prefix$image
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
done
