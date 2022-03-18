%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"
#include "astree.h"

// function prototypes from lex
int yyerror(char *s);
int yylex(void);
int debug=0; // set to 1 to turn on extra printing
char *StringArray[10];
int strindex =0;
Symbol** symTable;
SymbolTableIter iter;
Symbol* findSym;
ASTNode* program;
int arrSize;
int arrInd = 0;
int localOffset = -4;
int parPosition = 1;
char* manystring[100];

//load into registers
int registerind =0;
char *argRegStr[] = {"%%rdi", "%%rsi", "%%rdx", "%%rcx", "%%r8", "%%r9"};

//add string into register
int addString(char* s){
    int i = strindex++;
    StringArray[i]=s;
    return i;
}//end of addString

//write main register
void writemain(){
int count = 0;
while(count < strindex){
    printf("\n.LC%d:\n\t.string %s\n",count, StringArray[count]);
    count++;
    }//end while 
    
}//end of writemain



%}

/* token value data types */
%union { int ival; char* str; struct astnode_s * astnode}

/* Starting non-terminal */
%start prog
%type <astnode> function statements statement funcall Arguments Argument Expression declarations varDecl Parameters functions

/* Token types */
%token <ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA PLUS NUMBER
%token <str> STRING ID KWINT KWCHARS

%%

/******* Rules *******/
prog: declarations functions 
    {
       $$ = newNode(AST_PROGRAM);
       $$->child[0] = $1;
       $$->child[1] = $2;
       program = $$;
        
    }
    
functions:  /*empty char*/
          {$$ = 0;}
        |function functions
        {
            $1->next = $2;
            $$ = $1;
        }
        
function: ID LPAREN RPAREN LBRACE statements RBRACE
        {
            $$ = newNode(AST_FUNCTION);
            $$->valtype = T_STRING;
            $$->strval = $1;
            $$->child[0] = $3;
            $$->child[2] = $6;
            localOffset = -4;
            parPosition = 1;
            
        }
statements: /*empty char*/
          {$$ = 0;}
        |statement statements
        {
            $1->next = $2;
            $$ = $1;
        }

statement: funcall SEMICOLON
        {
        if (debug) printf("statement!\n");
            $$ = $1;
        }

funcall: ID LPAREN Arguments RPAREN
        {
            $$ = newNode(AST_FUNCALL);
            $$->strval = $1;
            $$->child[0] = $3;
        }
        
Arguments: /*empty char*/
          {$$ =0;}
          | Argument
          {
            if (debug) printf("Arguments!\n");
            $$=$1;
          }
          |Argument COMMA Arguments
          {
                $$ -> next = $3;
                $$ = $1;
          }
          
Argument: STRING
        {
        if (debug) printf("%s",$1);
         int sid = addString($1);
         char *code = (char*) malloc(strlen($1)*strlen($1)+128);   
         sprintf(code,"\tmovq\t$.LC%d, %s",sid,argRegStr[registerind]);
         registerind++;
         $$ = code;
        }
        | Expression
        {
                $$= newNode(AST_ARGUMENT);
                $$->child[0] = $1;
        }
        
Expression: NUMBER 
            {
            $$=newNode(AST_CONSTANT);
            $$->ival = $1;
            $$->valtype = T_INT;
            }
          | Expression PLUS Expression
          {
            $$ = newNode(AST_EXPRESSION);
            $$->child[0] = $1;
            $$->child[1] = $3;
            $$->ival = $2;
          }
          
declarations:/*empty char*/
          {$$ = "";}
          |varDecl SEMICOLON declarations
          {
                // $1->next = $3;
                //$$ = $1;
          }
          
varDecl: KWINT ID 
        {
            $$ = newNode(AST_VARDECL);
            $$->strval = $2;
            $$->valtype = T_INT;
        }
       | KWCHARS ID
       {
            $$ = newNode(AST_VARDECL);
            $$->strval = $2;
            $$->valtype = T_STRING;
            $$->ival = 0;
       }

Parameters: /*empty char*/
          {$$ = 0;}
          | varDecl
          {
              addSymbol(symTable, $1->strval, 1, $1->valtype, 0, parPosition);
              $1->ival = parPosition;
              parPosition++;
              $$=$1;
          }
          | varDecl COMMA Parameters{
            addSymbol(symTable, $1->strval, 1, $1-> valtype, 0, localOffset);
            $1->ival = parPosition;
            parPosition++;
            $1->next = $3;
            $$ = $1;
          }
          ;

%%
/******* Functions *******/
extern FILE *yyin; // from lex

int main(int argc, char **argv)
{
   if (argc==2) {
      yyin = fopen(argv[1],"r");
      if (!yyin) {
         printf("Error: unable to open file (%s)\n",argv[1]);
         return(1);
      }
    yyparse();
    genCodeFromASTree(program, 0, stdout);
   }
   return(0);
}

extern int yylineno; // from lex

int yyerror(char *s)
{
   fprintf(stderr, "Error: line %d: %s\n",yylineno,s);
   return 0;
}

int yywrap()
{
   return(1);
}
