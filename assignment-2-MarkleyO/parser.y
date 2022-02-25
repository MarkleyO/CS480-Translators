%{
// Taken from parser.y and parser-push.y sample code from lecture
#include <iostream>
#include <map>
#include "parser.hpp"

std::map<std::string, float> symbols;
std::string* program;

void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
%}

%locations
%define api.push-pull push
%define api.pure full

%union {
  std::string* str;
  int token;
}

%token <str> IDENTIFIER INTEGER FLOAT
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEBY EQ NEQ GT GTE LT LTE
%token <token> LPAREN RPAREN COMMA COLON
%token <token> INDENT DEDENT NEWLINE
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE TRUE FALSE


%type <str> program statements statement assignment expression operator if_block elif_block
%type <str> if_statement elif_statement else_statement while

%left PLUS MINUS
%left TIMES DIVIDEBY

%start program

%%

program
  : statements { program = $1; }
  ;

statements
  : statements statement { $$ = new std::string(*$1 + *$2); }
  | statement { $$ = $1; }
  ;

statement
  : assignment { $$ = $1; }
  | if_block { $$ = $1; }
  | while { $$ = $1; }
  | BREAK NEWLINE { $$ = new std::string("break;\n"); }
  ;

assignment
  : IDENTIFIER ASSIGN expression NEWLINE { $$ = new std::string(*$1 + " = " + *$3 + ";\n"); symbols[*$1] = 0; delete $1; }
  ;

expression
  : FLOAT { $$ = $1; }
  | INTEGER { $$ = $1; }
  | IDENTIFIER { $$ = $1; }
  | expression operator expression { $$ = new std::string(*$1 + " " + *$2 + " " + *$3); }
  | LPAREN expression RPAREN { $$ = new std::string("(" + *$2 + ")"); }
  | TRUE { $$ = new std::string("true");  }
  | FALSE { $$ = new std::string("false"); }
  ;

operator
  : PLUS { $$ = new std::string("+"); }
  | MINUS { $$ = new std::string("-"); }
  | TIMES { $$ = new std::string("*"); }
  | DIVIDEBY { $$ = new std::string("/"); }
  | EQ { $$ = new std::string("=="); }
  | NEQ { $$ = new std::string("!="); }
  | GT { $$ = new std::string(">"); }
  | GTE { $$ = new std::string(">="); }
  | LT { $$ = new std::string("<"); }
  | LTE { $$ = new std::string("<="); }
  ;

if_block
  : if_statement { $$ = $1; }
  | if_statement elif_block { $$ = new std::string(*$1 + *$2); }
  | if_statement else_statement { $$ = new std::string(*$1 + *$2); }
  | if_statement elif_block else_statement { $$ = new std::string(*$1 + *$2 + *$3); }
  ;

elif_block
  : elif_statement { $$ = $1; }
  | elif_block elif_statement { $$ = new std::string(*$1 + *$2); }
  ;

if_statement
  : IF expression COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "}\n"); }
  ;

elif_statement
  : ELIF expression COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("else if (" + *$2 + ") {\n" + *$6 + "}\n"); }
  ;

else_statement
  : ELSE COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("else {\n" + *$5 + "}\n"); }
  ;

while
  : WHILE expression COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("while (" + *$2 + ") {\n" + *$6 + "}\n"); }
  ;


%%

/*----------------------------------------------------------------
Function: yyerror:
  Whenever err type is parsed, a message will be sent to standard
  channel 'cerr'.
----------------------------------------------------------------*/
void yyerror(YYLTYPE* loc, const char* err){
  std::cerr << "Error: " << err << std::endl;
}
