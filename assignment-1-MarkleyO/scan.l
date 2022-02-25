%{
  #include <iostream>
  #include <string.h>
  #include <vector>

  struct token {
    std::string category;
    std::string content;
  };

  std::vector<struct token> scannedContents;

  void storeWord( std::string content, std::string category ) {
    struct token tok;
    tok.category = category;
    tok.content = content;
    scannedContents.push_back(tok);
  }

  int indents[ 200 ];
  int currentIndent = 0;

%}

%option yylineno
%option noyywrap

%%

  /* FORMATTING and JUNK */
"\n" {
  storeWord( "", "NEWLINE");
}
[ ]+ { }
#.* { }

  /* BOOLEANS */
"True" {
  storeWord( "TRUE", "BOOLEAN");
} 
"False" {
  storeWord( "FALSE", "BOOLEAN");
} 

  /* KEYWORDS */
"and" {
  storeWord( yytext, "AND");
}
"break" {
  storeWord( yytext, "BREAK");
}
"def" {
  storeWord( yytext, "DEF");
}
"elif" {
  storeWord( yytext, "ELIF");
}
"else" {
  storeWord( yytext, "ELSE");
}
"for" {
  storeWord( yytext, "FOR");
}
"if" {
  storeWord( yytext, "IF");
}
"not" {
  storeWord( yytext, "NOT");
}
"or" {
  storeWord( yytext, "OR");
}
"return" {
  storeWord( yytext, "RETURN");
}
"while" {
  storeWord( yytext, "WHILE");
}

  /* OPERATORS */
"=" {
  storeWord( yytext, "ASSIGN");
}
"+" {
  storeWord( yytext, "PLUS");
}
"-" {
  storeWord( yytext, "MINUS");
}
"*" {
  storeWord( yytext, "TIMES");
}
"/" {
  storeWord( yytext, "DIVIDEBY");
}
"==" {
  storeWord( yytext, "EQ");
}
"!=" {
  storeWord( yytext, "NEQ");
}
">" {
  storeWord( yytext, "GT");
}
">=" {
  storeWord( yytext, "GTE");
}
"<" {
  storeWord( yytext, "LT");
}
"<=" {
  storeWord( yytext, "LTE");
}

  /* PUNCTUATION */
"(" {
  storeWord( yytext, "LPAREN");
}
")" {
  storeWord( yytext, "RPAREN");
}
"," {
  storeWord( yytext, "COMMA");
}
":" {
  storeWord( yytext, "COLON");
}

  /* IDENTIFIER, FLOAT, and INTEGER */
[a-zA-Z_][a-zA-Z0-9_]* {
  storeWord( yytext, "IDENTIFIER");
}
[0-9]+ {
  storeWord( yytext, "INTEGER");
}
[0-9]*\.[0-9]+ {
  storeWord( yytext, "FLOAT");
}


%%

int main() {
  // yylex();
  // std::cout << "HELLO" << std::endl;
  if( !yylex() ) {
    for ( int i = 0; i < scannedContents.size(); i++ ) {
      if( scannedContents[i].category == "INTEGER" ){
        std::cout << scannedContents[i].category << "\t" << atoi(scannedContents[i].content.c_str()) << std::endl;
      } else if( scannedContents[i].category == "FLOAT" ) {
        std::cout << scannedContents[i].category << "\t" << atof(scannedContents[i].content.c_str()) << std::endl;
      } else {
        std::cout << scannedContents[i].category << "\t" << scannedContents[i].content << std::endl;
      }
    }
  }
}
