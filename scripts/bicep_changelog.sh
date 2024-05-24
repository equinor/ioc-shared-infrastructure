#!/bin/bash

rootPath=$1

prefix="$rootPath/resources/"
if [ -f $rootPath/BICEP_CHANGELOG.md ]; then
    rm $rootPath/BICEP_CHANGELOG.md
fi

now=$(date '+%Y-%m-%d %H:%M:%S')

touch $rootPath/BICEP_CHANGELOG.md
echo "# Bicep Change Log $now" >> $rootPath/BICEP_CHANGELOG.md
for dir in $rootPath/resources/*
do
    test -d $dir || continue
    file=($dir/azuredeploy.bicep)
    test -f $file || continue
    line=$(head -n 1 $file)
    if [[ $line != *Version* ]]; then
        line="Version not found in file"
    fi
    file=${file#"$prefix"}
    printf "%-60s $line\n" $file  >> $rootPath/BICEP_CHANGELOG.md
done
