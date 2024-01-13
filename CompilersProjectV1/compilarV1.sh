#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Use like this: $0 <filename>"
else
	lex $1
	cc lex.yy.c -ll
fi


