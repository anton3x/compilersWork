#!/bin/sh

lex $1
cc lex.yy.c -ll

