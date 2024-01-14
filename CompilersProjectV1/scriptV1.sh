#!/bin/sh

if [ $# -ne 1 ]
then
	echo "How to use:"
    echo "[ $0 filename ] (do not include extension, ex: .l or .y)!!!"
else
	lex $1.l
	cc lex.yy.c -ll
fi

