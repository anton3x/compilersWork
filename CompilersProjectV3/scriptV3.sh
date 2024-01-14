if [ $# -ne 1 ]
then
    echo "How to use:"
    echo "[ $0 filename ] (do not include extension, ex: .l or .y)!!!"
else
    bison -d $1.y
    lex $1.l
    gcc $1.tab.c lex.yy.c -lfl
fi