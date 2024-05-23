#!/bin/bash

prefix="../resources/"
if [ -f ../BICEP_CHANGELOG.md ]; then
    rm ../BICEP_CHANGELOG.md
fi

now=$(date '+%Y-%m-%d %H:%M:%S')

touch ../BICEP_CHANGELOG.md
echo "# Bicep Change Log $now" >> ../BICEP_CHANGELOG.md
for dir in ../resources/*
do
    test -d $dir || continue
    file=($dir/azuredeploy.bicep)
    test -f $file || continue
    line=$(head -n 1 $file)
    if [[ $line != *Version* ]]; then
        line="Version not found in file"
    fi
    file=${file#"$prefix"}
    printf "%-60s $line\n" $file  >> ../BICEP_CHANGELOG.md
done
