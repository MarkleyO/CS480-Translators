%option noyywrap
%option yylineno

%{
#include <iostream>
#include <stack>
#include <cstdlib>
#include "parser.hpp"


YYSTYPE yylval;
YYLTYPE yylloc;

yypstate* pstate = yypstate_new();

#define PUSH_TOKEN(token) do { \
  int s = yypush_parse(pstate, token, &yylval, &yylloc); \
  if (s != YYPUSH_MORE) { \
    yypstate_delete(pstate); \
    return s; \
  } \
} while (0)

std::stack<int> _indent_stack;
%}

%%

%{
if (_indent_stack.empty()) {
  _indent_stack.push(0);
}
%}

^[ \t]*\r?\n  /* Skip blank lines */

^[ \t]*#.*\r?\n  /* Skip whole-line comments. */

#.*$  /* Skip comments on the same line as a statement. */

^[ \t]+ {
  if (_indent_stack.top() < yyleng) {
    PUSH_TOKEN((yylval.token = INDENT));
    _indent_stack.push(yyleng);
  } else {
    while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
      _indent_stack.pop();
      PUSH_TOKEN((yylval.token = DEDENT));
    }

    if (_indent_stack.empty()) {
      std::cerr << "Error: Incorrect indentation on line " << yylineno
        << std::endl;
      return 1;
    }
  }
}

^[^ \t\r\n]+ {
  while (_indent_stack.top() != 0) {
    _indent_stack.pop();
    PUSH_TOKEN((yylval.token = DEDENT));
  }
  REJECT;
}

\r?\n {
  PUSH_TOKEN((yylval.token = NEWLINE));
}

<<EOF>> {
  while(_indent_stack.top() != 0) {
    _indent_stack.pop();
    PUSH_TOKEN((yylval.token = DEDENT));
  }
  int s = yypush_parse(pstate, 0, NULL, NULL);
  yypstate_delete(pstate);
  return s;
}

[ \t]  /* Ignore spaces that haven't been handled above. */

"and" { PUSH_TOKEN((yylval.token = AND)); }

"break" { PUSH_TOKEN((yylval.token = BREAK)); }

"def" { PUSH_TOKEN((yylval.token = DEF)); }

"elif" { PUSH_TOKEN((yylval.token = ELIF)); }

"else" { PUSH_TOKEN((yylval.token = ELSE)); }

"for" { PUSH_TOKEN((yylval.token = FOR)); }

"if" { PUSH_TOKEN((yylval.token = IF)); }

"not" { PUSH_TOKEN((yylval.token = NOT)); }

"or" { PUSH_TOKEN((yylval.token = OR)); }

"return" { PUSH_TOKEN((yylval.token = RETURN)); }

"while" { PUSH_TOKEN((yylval.token = WHILE)); }

"True" { PUSH_TOKEN((yylval.token = TRUE)); }

"False" { PUSH_TOKEN((yylval.token = FALSE)); }

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(IDENTIFIER);
}

[0-9]*"."[0-9]+ {
  yylval.str = new std::string(yytext, yyleng);
  // yylval.value = atof(yytext);
  PUSH_TOKEN(FLOAT);
}

[0-9]+ {
  yylval.str = new std::string(yytext, yyleng);
  //yylval.value = atof(yytext);
  PUSH_TOKEN(INTEGER);
}

"=" { PUSH_TOKEN(ASSIGN); }

"+" { PUSH_TOKEN(PLUS); }

"-" { PUSH_TOKEN(MINUS); }

"*" { PUSH_TOKEN(TIMES); }

"/" { PUSH_TOKEN(DIVIDEBY); }

"==" { PUSH_TOKEN(EQ); }

"!=" { PUSH_TOKEN(NEQ); }

">"  { PUSH_TOKEN(GT); }

">=" { PUSH_TOKEN(GTE); }

"<" { PUSH_TOKEN(LT); }

"<=" { PUSH_TOKEN(LTE); }

"(" { PUSH_TOKEN(LPAREN); }

")" { PUSH_TOKEN(RPAREN); }

"," { PUSH_TOKEN(COMMA); }

":" { PUSH_TOKEN(COLON); }

. {
  std::cerr << "Unrecognized token on line " << yylineno << ": " << yytext
    << std::endl;
  PUSH_TOKEN(yytext[0]);
}

%%
