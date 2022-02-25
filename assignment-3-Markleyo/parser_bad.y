%{
#include <iostream>
#include <set>
#include <vector>

#include "parser.hpp"


extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string* translate_boolean_str(std::string* boolean_str);

Node *seed;
Branch *trunk;

Branch *second;

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
//std::string* target_program;
//std::set<std::string> symbols;
%}

%code requires{
  #include "ast.hpp"
}
/* Enable location tracking. */
%locations
%union {
  int token;
  std::string* str;
  Node *tree;
  Branch *syntax_tree;
}

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
/* %define api.value.type { std::string* } */

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token <str> IDENTIFIER
%token <str> FLOAT INTEGER BOOLEAN
%token <token> INDENT DEDENT NEWLINE
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> EQ NEQ GT GTE LT LTE
%token <token> LPAREN RPAREN COMMA COLON

%type <tree> program statements statement expression primary_expression negated_expression
%type <tree> if_statement elif_blocks else_block condition block while_statement break_statement assign_statement

/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%right NOT
%left EQ NEQ GT GTE LT LTE
%left PLUS MINUS
%left TIMES DIVIDEDBY

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */

/*
 * This is the goal/start symbol.  Once all of the statements in the entire
 * source program are translated, this symbol receives the string containing
 * all of the translations and assigns it to the global target_program, so it
 * can be used outside the parser.
 */
program
  : statements { seed = new Node("Block", "", $1);
      trunk = new Branch(0, "Block", "");
    }
  ;

/*
 * The `statements` symbol represents a set of contiguous statements.  It is
 * used to represent the entire program in the rule above and to represent a
 * block of statements in the `block` rule below.  The second production here
 * simply concatenates each new statement's translation into a running
 * translation for the current set of statements.
 */
statements
  : statement {
      Node *temp = new Node("", "");
      temp->add_child($1);
      $$ = temp;
      second = new Branch(1, "Statement", "");
    }
  | statements statement {
      Node *temp = new Node("", "", $1);
      temp->add_child($2);
      $$ = temp;
    }
  ;

/*
 * This is a high-level symbol used to represent an individual statement.
 */
statement
  : assign_statement { $$ = $1; }
  | if_statement { $$ = $1; }
  | while_statement { $$ = $1; }
  | break_statement { $$ = $1; }
  ;

/*
 * A primary expression is a "building block" of an expression.
 */
primary_expression
  : IDENTIFIER {$$ = new Node("Identified", *$1); delete $1; }
  | FLOAT {$$ = new Node("Float", *$1); delete $1; }
  | INTEGER {$$ = new Node("Integer", *$1); delete $1; }
  | BOOLEAN {
      if (*$1 == "True")
        $$ = new Node("Boolean", "1");
      if (*$1 == "False")
        $$ = new Node("Boolean", "0");
      delete $1;
    }
  | LPAREN expression RPAREN { $$ = $2; }
  ;

/*
 * Symbol representing a boolean "not" operation.
 */
negated_expression
  : NOT primary_expression { $$ = new Node("NOT", "", NULL, $2); }
  ;

/*
 * Symbol representing algebraic expressions.  For most forms of algebraic
 * expression, we generate a translated string that simply concatenates the
 * C++ translations of the operands with the C++ translation of the operator.
 */
expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression { $$ = new Node("PLUS", "", $1, $3); }
  | expression MINUS expression { $$ = new Node("MINUS", "", $1, $3); }
  | expression TIMES expression { $$ = new Node("TIMES", "", $1, $3); }
  | expression DIVIDEDBY expression { $$ = new Node("DIVIDEBY", "", $1, $3); }
  | expression EQ expression { $$ = new Node("EQ", "", $1, $3); }
  | expression NEQ expression { $$ = new Node("NEQ", "", $1, $3); }
  | expression GT expression { $$ = new Node("GT", "", $1, $3); }
  | expression GTE expression { $$ = new Node("GTE", "", $1, $3); }
  | expression LT expression { $$ = new Node("LT", "", $1, $3); }
  | expression LTE expression { $$ = new Node("LTE", "", $1, $3); }
  ;

/*
 * This symbol represents an assignment statement.  For each assignment
 * statement, we first make sure to insert the LHS identifier into the symbol
 * table, since it is potentially a new symbol.  Then, we generate a C++
 * translation for the whole assignment by combining the C++ translations of
 * the LHS and the RHS along with an equals sign and a semi-colon, to make sure
 * we have proper C++ punctuation.
 */
assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE {
      Node *identifier = new Node("Identifier", *$1);
      delete $1;
      $$ = new Node("Assignment", "", identifier, $3);
    }
  ;

/*
 * A `block` represents the collection of statements associated with an
 * if, elif, else, or while statement.  The C++ translation for a block of
 * statements is wrapped in curly braces ({}) instead of INDENT and DEDENT.
 */
block
  : INDENT statements DEDENT { $$ = new Node("Block", "", $2); }
  ;

/*
 * This symbol represents a boolean condition, used with an if, elif, or while.
 * The C++ translation of a condition concatenates the C++ translations of its
 * operators with one of the C++ boolean operators && or ||.
 */
condition
  : expression { $$ = $1; }
  | condition AND condition { $$ = new Node("AND", "", $1, $3); }
  | condition OR condition { $$ = new Node("OR", "", $1, $3); }
  ;

/*
 * This symbol represents an entire if statement, including optional elif
 * blocks and an optional else block.  The C++ translations for the blocks
 * are simply combined here into one larger translation, and the if condition
 * is wrapped in parentheses, as is required in C++.
 */
if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block {
      Node *if_node = new Node("IF", "");
      if_node->add_child($2);
      if_node->add_child($5);
      if ($6 != NULL) {
        if_node->add_child($6);
      }
      if ($7 != NULL) {
        if_node->add_child($7);
      }
      $$ = if_node;
    }
  ;

/*
 * This symbol represents zero or more elif blocks to be attached to an if
 * statement.  When a new elif block is recognized, the Pythonic "elif" is
 * translated to the C++ "else if", and the condition is wrapped in parens.
 */
elif_blocks
  : %empty { $$ = NULL; }
  | elif_blocks ELIF condition COLON NEWLINE block {
      if ($1 == NULL) {
        Node *elif_node = new Node("ELIF", "");
        elif_node->add_child($3);
        elif_node->add_child($6);
        $$ = elif_node;
      } else {
        Node *elif_node = new Node("ELIF", "", $1);
        elif_node->add_child($3);
        elif_node->add_child($6);
        $$ = elif_node;
      }
    }
  ;

/*
 * This symbol represents an if statement's optional else block.
 */
else_block
  : %empty { $$ = NULL; }
  | ELSE COLON NEWLINE block { $$ = $4;}
  ;


/*
 * This symbol represents a while statement.  The C++ translation wraps the
 * while condition in parentheses.
 */
while_statement
  : WHILE condition COLON NEWLINE block { $$ = new Node("While", "", $2, $5); }
  ;

/*
 * This symbol represents a break statement.  The C++ translation simply adds
 * a semicolon.
 */
break_statement
  : BREAK NEWLINE { $$ = new Node("BREAK", "", NULL, NULL); }
  ;

%%

/*
 * This is our simple error reporting function.  It prints the line number
 * and text of each error.
 */
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string* translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    return new std::string("true");
  } else {
    return new std::string("false");
  }
}
