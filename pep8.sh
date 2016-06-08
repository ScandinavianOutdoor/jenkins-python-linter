#!/bin/bash
WORKSPACE=$1
BRANCH=$2
SHA=$3

cd $WORKSPACE
rm junit.xml

git fetch --all
git reset --hard $SHA
LIST=$(git diff --name-only origin/$BRANCH | grep \.py$ | grep -v migrations)
if [ -n "$LIST" ]; then
    echo $LIST | \xargs git diff origin/$BRANCH -- | flake8 --max-line-length=99 --diff > /tmp/flake.txt
else
    > /tmp/flake.txt
fi


junit_conversor /tmp/flake.txt junit.xml
touch junit.xml

if [ ! -s junit.xml ]
then
    cp /var/lib/jenkins/junit_success.xml junit.xml
    time=$(date '+%Y-%m-%dT%H:%M:%S')
    sed -i "s/TIME_STAMP/$time/g" junit.xml
    touch junit.xml
fi
