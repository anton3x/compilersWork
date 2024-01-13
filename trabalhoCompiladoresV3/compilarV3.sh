if [ $# -ne 1 ]
then
    echo "Forma de utilizacao:"
    echo "[ $0 nomeDoFicheiro ] (nao incluir extensao)!!!"
else
    bison -d $1.y
    lex $1.l
    gcc $1.tab.c lex.yy.c -lfl
fi