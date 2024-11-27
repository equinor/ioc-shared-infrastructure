#!/bin/bash

rootPath=$1

prefix="$rootPath/resources/"
if [ -f $rootPath/BICEP_RESOURCE_VERSIONS.md ]; then
    rm $rootPath/BICEP_RESOURCE_VERSIONS.md
fi

touch $rootPath/BICEP_RESOURCE_VERSIONS.md

printf "[Auto-generated version-log]\n\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
printf "# Bicep Versions\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
printf "| Resource | Version | Changed | Commit |\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
printf "|----------|----------|----------|----------|\n" >> $rootPath/BICEP_RESOURCE_VERSIONS.md
for dir in $rootPath/resources/*
do
    test -d $dir || continue
    file=($dir/azuredeploy.bicep)
    test -f $file || continue
    line=$(head -n 1 $file)
    if [[ $line != *Version* ]]; then
        line="Version not found in file"
    fi
    changeDate=$(git log -1 --pretty="format:%ci" -- $file)
    commit=$(git log -1 --pretty="format:%h" -- $file)
    file=${file#"$prefix"}
    line=${line#"// "}
    line=${line#"Version"}
    printf "| %-70s | $line | $changeDate | $commit |\n" $file  >> $rootPath/BICEP_RESOURCE_VERSIONS.md
done
