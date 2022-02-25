%{
#include <iostream>
#include <stdio.h>

int num_chars = 0;
int num_words = 0;
int num_lines = 0;
int num_ints = 0;
%}

%option noyywrap

%%

  /* IGNORING JUNK */
"\n" {
  std::cout << "NEWLINE" << std::endl;
}


  /* IGNORING WHITESPACE */
" +" {
  std::cout << "SPACE";
}

  /* KEYWORDS SECTION */
"and" {
  std::cout << "AND" << "\tand" << std::endl;
}
"break" {
  std::cout << "BREAK" << "\tbreak" << std::endl;
}
"def" {
  std::cout << "DEF" << "\tdef" << std::endl;
}
"elif" {
  std::cout << "ELIF" << "\telif" << std::endl;
}
"else" {
  std::cout << "ELSE" << "\telse" << std::endl;
}
"for" {
  std::cout << "FOR" << "\tfor" << std::endl;
}
"if" {
  std::cout << "IF" << "\tif" << std::endl;
}
"not" {
  std::cout << "NOT" << "\tnot" << std::endl;
}
"or" {
  std::cout << "OR" << "\tor" << std::endl;
}
"return" {
  std::cout << "RETURN" << "\treturn" << std::endl;
}
"while" {
  std::cout << "WHILE" << "\twhile" << std::endl;
}

  /* OPERATORS SECTION */
"=" {
  std::cout << "ASSIGN" << "\t=" << std::endl;
}
"+" {
  std::cout << "PLUS" << "\t+" << std::endl;
}
"-" {
  std::cout << "MINUS" << "\t-" << std::endl;
}
"*" {
  std::cout << "TIMES" << "\t*" << std::endl;
}
"/" {
  std::cout << "DIVIDEBY" << "\t/" << std::endl;
}
"==" {
  std::cout << "EQ" << "\t==" << std::endl;
}
"!=" {
  std::cout << "NEQ" << "\t!=" << std::endl;
}
">" {
  std::cout << "GT" << "\t>" << std::endl;
}
">=" {
  std::cout << "GTE" << "\t>=" << std::endl;
}
"<" {
  std::cout << "LT" << "\t<" << std::endl;
}
"<=" {
  std::cout << "LTE" << "\t<=" << std::endl;
}

  /* PUNCTUATION SECTION */
"(" {
  std::cout << "LPAREN" << "\t(" << std::endl;
}
")" {
  std::cout << "RPAREN" << "\t)" << std::endl;
}
"," {
  std::cout << "COMMA" << "\t," << std::endl;
}
":" {
  std::cout << "COLON" << "\t:" << std::endl;
}

  /* GENERAL TYPES */
#.* {
  std::cout << "COMMENT" << std::endl;
}
[a-zA-Z_][a-zA-Z0-9_]* {
  std::cout << "IDENTIFIER" << "\t" << yytext << std::endl;
}
[0-9]+ {
  std::cout << "INTEGER" << "\t" << atoi(yytext) << std::endl;
}
[0-9]*\.[0-9]+ {
  std::cout << "FLOAT" << "\t" << atof(yytext) << std::endl;
}

%%

int main() {
  yylex();
  double n = atof("90.24");
  std::cout << n << std::endl;
  std::cout << num_lines << "\t" << num_words << "\t" << num_chars
    << "\t" << num_ints << std::endl;
  return 0;
}
