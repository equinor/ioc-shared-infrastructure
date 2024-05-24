#!/bin/bash

rootPath=$1

prefix="$rootPath/resources/"
if [ -f $rootPath/BICEP_RESOURCE_VERSIONS.md ]; then
    rm $rootPath/BICEP_RESOURCE_VERSIONS.md
fi

now=$(date '+%Y-%m-%d %H:%M:%S')

touch $rootPath/BICEP_RESOURCE_VERSIONS.md

printf "# Bicep Version Log $now\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
printf "| Resource | Version |\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
printf "|----------|----------|\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
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
    line=${line#"// "}
    line=${line#"Version"}
    printf "| %-70s | $line |\n" $file  >> $rootPath/BICEP_RESOURCE_VERSIONS.md
done
