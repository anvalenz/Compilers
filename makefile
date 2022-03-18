#
# Make file for simple scanner and parser example
#

# flags and defs for built-in compiler rules
CFLAGS = -I. -Wall -Wno-unused-function
CC = gcc

# default rule build the parser
all: ptest

# yacc "-d" flag creates y.tab.h header
y.tab.c: parser.y
	yacc -d parser.y

# lex rule includes y.tab.c to force yacc to run first
# lex "-d" flag turns on debugging output
lex.yy.c: parser.l y.tab.c
	lex parser.l

symtable.o: symtable.c symtable.h
	gcc -c symtable.c
	
astree.o: astree.c astree.h symtable.h
	gcc -c astree.c

ltest: scanner.l
	lex scanner.l
	gcc -DLEXONLY lex.yy.c -o ltest -ll 
	
ptest: lex.yy.o y.tab.o symtable.o symtable.h astree.o astree.h
	gcc -o ptest y.tab.o lex.yy.o symtable.o astree.o

clean: 
	rm -f lex.yy.c a.out output y.tab.c y.tab.h *.o ptest ltest test

