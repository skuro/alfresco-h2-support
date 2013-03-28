#!/bin/bash
#
###############################################################################
#
# Copyright (c) 2011 Carlo Sciolla
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
###############################################################################
#
# Compares the current H2 Support scripts with a given Alfresco distribution
#
# Author: Carlo Sciolla <skuro@skuro.tk>

function usage(){
  echo "Usage: $0 </path/to/alfresco.war>"
  exit 1
}

if [ $# = 0 ]
then
  usage
fi

ALF=$1

TMP=`mktemp -d -t alfh2`

echo "-- Extracting Alfresco"

unzip -d $TMP $ALF > /dev/null
DIAL="$TMP/WEB-INF/classes/alfresco/dbscripts/create/org.hibernate.dialect.PostgreSQLDialect"
DIAL_H2="src/main/resources/alfresco/dbscripts/create/org.hibernate.dialect.H2Dialect"

echo "-- Comparing creation scripts"

for file in $DIAL/*
do
    name=`basename $file`
    changed=`diff -wBb <(grep -ve "^--" $DIAL_H2/$name) <(grep -ve "^--" $file)`
    if [ "x$changed" != "x" ]
    then
        echo $'\e[00;31m'$name$'\e[00m changed:'
        echo "$changed"
    fi
done

SQLMAP="$TMP/WEB-INF/classes/alfresco/ibatis/org.hibernate.dialect.PostgreSQLDialect"
SQLMAP_H2="src/main/resources/alfresco/ibatis/org.hibernate.dialect.H2Dialect"

echo "-- Comparing SQL maps"

for file in $SQLMAP/*
do
    name=`basename $file`
    changed=`diff -wBb <(cat $SQLMAP_H2/$name | sed '/<!--/,/-->/d') <(cat $file | sed '/<!--/,/-->/d')`
    if [ "x$changed" != "x" ]
    then
        echo $'\e[00;31m'$name$'\e[00m changed:'
        echo "$changed"
    fi
done

echo "-- Cleaning up"

rm -Rf $TMP
