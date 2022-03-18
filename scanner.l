%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef LEXONLY
#include "y.tab.h"
extern int debug; // declared and set in parser.y
#else
typedef union { int ival; char* str; } yystype;
#define YYSTYPE yystype
yystype yylval;
#define LPAREN 1
#define RPAREN 2
#define LBRACE 3
#define RBRACE 4
#define SEMICOLON 5
#define STRING 6
#define ID 7
#define STRING 8
#define COMMA 9
#define NUMBER 10
#define PLUS 11
#define KWINT 12
#define KWCHARS 13
int debug=0;
#endif
%}

%option yylineno

/****** Token Patterns ******/
%%
[ \t\n\r]+ { /* skipping white space */ }

\( {
            if (debug) printf("LEFT PARENTHESIS\n");
            yylval.ival = strtol(yytext,0,10);
            return(LPAREN);
         }
\) {
            if (debug) printf("RIGHT PARENTHESIS\n");
            yylval.ival = strtol(yytext,0,10);
            return(RPAREN);
         }
\{ {
            if (debug) printf("LEFT BRACE\n");
            yylval.ival = strtol(yytext,0,10);
            return(LBRACE);
         }
\} {
            if (debug) printf("RIGHT BRACE\n");
            yylval.ival = strtol(yytext,0,10);
            return(RBRACE);
         }
\;         {
            if (debug) printf("SEMICOLON\n");
            yylval.ival = strtol(yytext,0,10);
            return(SEMICOLON);
         }
[a-zA-z][a-zA-z0-9]*  {
            if (debug) printf("Function Name: (%s)\n",yytext);
            yylval.str = strdup(yytext);
            return(ID);
         }
\"[^\"]*\" {
            if (debug) printf("String: (%s)\n",yytext);
            yylval.str = strdup(yytext);
            return(STRING);
            }

\,          {
            if (debug) printf("COMMA\n");
            yylval.ival = strtol(yytext,0,10);
            return(COMMA);
            }
[0-9]*      {
            if (debug) printf("NUMBER: (%s)\n",yytext);
            yylval.ival = strtol(yytext,0,10);
            return(NUMBER);
            }
\+          {
            if (debug) printf("PLUS\n");
            yylval.ival = strtol(yytext,0,10);
            return(PLUS);
            }
int          {
            if (debug) printf("int\n");
            yylval.ival = strtol(yytext,0,10);
            return(KWINT);
            }
char          {
            if (debug) printf("char\n");
            yylval.ival = strtol(yytext,0,10);
            return(KWCHARS);
            }
%%

//
#ifdef LEXONLY

// A main for standalone testing (uses just stdin as input)
int main(int argc, char **argv) 
{
   do {
      yylex();
   } while (1);
   // while (!feof(stdin)); doesn't work if redirecting a file
   // in because the file is read in and buffered, and eof is
   // true too early, causing lex to stop; rather, use while(1)
   // and then do a hard exit in yywrap(); ugly, but works!
   return 0;
}

int yywrap()
{
   exit(0); // hard exit!
   //return(1);
}

#endif // LEXONLY
