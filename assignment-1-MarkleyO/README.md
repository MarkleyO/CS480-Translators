# Assignment 1
**Due by 11:59pm on Monday, 4/26/2021**<br/>
**Demo due by 11:59pm on Monday, 5/10/2021**

Throughout this course, we'll be working on building a compiler for a subset of the language Python.  In this particular assignment, we'll implement the first phase of our compiler's front-end: the scanner.  We'll use a widely-used scanner generator called [Flex](https://github.com/westes/flex/) to do this.

There are a few parts to this assignment, each outlined below.


## 1. Sign up for Campuswire

This first part of this assignment is simple and doesn't involve coding. Just join our course on Campuswire using your ONID email address. I already sent an email invite to join our Campuswire course to your ONID email address. Alternatively, you can also find a link and invite code to join Campuswire on the homepage of our Canvas site for the course. If you have trouble connecting to our course on Campuswire, please catch up with me after lecture or drop into my office hours, and I’ll help you join.

We'll be using Campuswire as our main communication platform for the course. Campuswire has both a StackOverflow-style Q&A forum, called the "class feed", as well as live chat rooms, so it should hopefully fulfill all of our course communication needs. For this reason, please use Campuswire exclusively for questions you have about the course. I (Hess) and the TAs will be on Campuswire, just like you and your fellow students, so you can feel confident about getting the answers you need there.

I strongly encourage you to also spend time answering your fellow classmates’ questions on Campuswire. This will not only enable everyone to get help quickly, but it will also help you improve your understanding of the material, since teaching someone else is the best way to learn something. As an extra incentive to answer questions on Campuswire, extra credit will be awarded to the most active Campuswire participants at the end of the course (based on Campuswire’s reputation score).

## 2. Implement a scanner for a simplified Python using Flex

Flex is a tool that's widely-used for generating scanners.  To implement a scanner using Flex, you must specify a) a set of regular expressions corresponding to microsyntax patterns in your source language and b) a set of actions to be taken when each of the patterns is matched.  We'll talk more about the details of Flex in lecture.

Your main task in this assignment is to use Flex to implement a scanner for a subset of Python.  For information on the Python language, please see the Python documentation: https://docs.python.org/3/tutorial/.

The scanner you implement should recognize the syntactic categories described below.  Each time a token in the source code is matched, your scanner should print a line to `stdout` that contains the label for the syntactic category (as specified below) and the value of the lexeme corresponding to the matched token.  For example, if your scanner recognizes an identifier `cat2` in the source code, it should print the following line to `stdout`:
```
IDENTIFIER    cat2
```
Or, if your scanner recognizes a floating point number `8.0`, it should print something like the following line:
```
FLOAT         8.0
```
Such a line should be printed for every token in the input source file.

### Syntactic categories to be recognized

Your scanner should recognize the following syntactic categories.  The label for each category is specified.  Note that these categories represent a simplified subset of the Python language.

  * `IDENTIFIER` - An identifier must begin with an alphabetic character or an underscore and can then contain any number of alphanumeric characters and/or underscores, e.g. `foo`, `cat2`, `an_identifier`, `anotherIdentifier`.

  * `FLOAT` - A floating point number consists of zero or more numerical characters followed by a decimal point (i.e. `.`) followed by one or more numerical characters.  Examples are `3.1415`, `16.0`, `0.5`, `.66667`.  For this assignment, you only need to recognize *unsigned* floating point numbers (i.e. no negative numbers).  When a floating point number is recognized by your scanner, you should use a function like [`atof()`](https://www.cplusplus.com/reference/cstdlib/atof/) to parse it into a numerical value when printing it to `stdout`.

  * `INTEGER` - An integer consists of one or more numerical characters, e.g. `8`, `32`, `0`, `111`.  For this assignment, you only need to recognize *unsigned* integers (i.e. no negative numbers).  When an integer is recognized by your scanner, you should use a function like [`atoi()`](https://www.cplusplus.com/reference/cstdlib/atoi/) to parse it into a numerical value when printing it to `stdout`.

  * `BOOLEAN` - There are two boolean values in Python: `True` and `False`.  When a boolean value is recognized by your scanner, you should map it to either `1` or `0` or to a C++ `bool` value when printing it to `stdout`.

  * The following are keywords your scanner should recognize (along with the label of the corresponding syntactic category):
    * `AND` - The keyword `and`.
    * `BREAK` - The keyword `break`.
    * `DEF` - The keyword `def`.
    * `ELIF` - The keyword `elif`.
    * `ELSE` - The keyword `else`.
    * `FOR` - The keyword `for`.
    * `IF` - The keyword `if`.
    * `NOT` - The keyword `not`.
    * `OR` - The keyword `or`.
    * `RETURN` - The keyword `return`.
    * `WHILE` - The keyword `while`.

  * The following are operators your scanner should recognize (along with the label of the corresponding syntactic category):
    * `ASSIGN` - The operator `=`.
    * `PLUS` - The operator `+`.
    * `MINUS` - The operator `-`.
    * `TIMES` - The operator `*`.
    * `DIVIDEDBY` - The operator `/`.
    * `EQ` - The operator `==`.
    * `NEQ` - The operator `!=`.
    * `GT` - The operator `>`.
    * `GTE` - The operator `>=`.
    * `LT` - The operator `<`.
    * `LTE` - The operator `<=`.

  * The following are punctuation marks your scanner should recognize (along with the label of the corresponding syntactic category):
    * `LPAREN` - Left parenthesis `(`.
    * `RPAREN` - Right parenthesis `)`.
    * `COMMA` - Comma `,`.
    * `COLON` - Colon `:`.

  * `NEWLINE` - Python statements are delimited by newlines, so you must recognize newlines after statements.  For this assignment, you may assume that all statements span just a single line and are not broken over multiple lines (e.g. with backslashes).  When a newline is recognized, your scanner only needs to print a line containing the label `NEWLINE` without a value.

  * `INDENT` and `DEDENT` - In Python, indentation is used to group statements into blocks, so you must recognize when indentation increases and decreases.  See the next section for more on how this will work.  When indentation increases or decreases, your scanner only needs to print a line containing the corresponding label (i.e. `INDENT` or `DEDENT`) without a value.

In addition to recognizing the above, your scanner should have the following behaviors:

  * Whitespace between words should be ignored.

  * Lines that are completely blank or that contain only whitespace should be ignored.

  * Whole-line comments should be ignored.  A whole-line comment is one that does not occur on the same line as a statement and may optionally be indented.  In Python, a comment begins with a `#` character and continues to the end of the line.  Importantly, a comment line should not generate a `NEWLINE`.  For this assignment, you do not need to worry about comments that occur on the same line as a statement.

## 3. Handle indentation

In Python, indentation is used to group statements into blocks.  For example, all of the statements in an `if` block are indented one level further than the `if` statement itself, like below:
```python
if x > 0:
    a = 2
    b = 4
    c = 8
```
Such indentation is also used to group function bodies, loop bodies, etc., e.g.:
```python
def sum_to(n):
    s = 0
    i = 0
    while i < n:
        s = s + i
        i = i + 1

    return s
```
In the above example, note that the indentation level increases twice: once to indicate the body of the `sum_to()` function and a second time to indicate the body of the `while` loop.

Because of the way Python uses indentation, [it is not a context-free language](http://trevorjim.com/python-is-not-context-free/).  This makes things challenging if we hope to use a standard parser generator like [Bison](https://www.gnu.org/software/bison/) to create a parser for Python (which we will do in future assignments), since such parser generators generally operate only on context-free grammers.

Luckily, we can formulate our scanner in such a way as to allow us to use a context-free parser.  In particular, we can implement our scanner so that it keeps track of indentation levels in the code, emitting an `INDENT` token every time indentation increases a level and emitting a `DEDENT` token every time indentation decreases a level.  In essence, these `INDENT` and `DEDENT` tokens respectively play the same role as opening (`{`) and closing (`}`) braces in a language like C++, marking the beginning and end of a block of statements.

Your most challenging task in this assignment is to add rules to your scanner definition to keep track of indentation in the source code and to emit `INDENT` and `DEDENT` tokens when the indentation level changes.  This can be done using a stack, as described in the Python documentation:

https://docs.python.org/3/reference/lexical_analysis.html#indentation

For this assignment, you may treat spaces and tabs the same way, i.e. spaces and tabs can be used interchangeably for indentation in the source code and may even be combined in a single line of code.  In other words, for the purposes of this assignment, the following should all be considered as equivalent indentation:
  * 4 space characters
  * 4 tab characters
  * 2 space characters and 2 tab characters
  * 1 space, 1 tab, 1 space, and 1 tab
  * etc.

As an example of how this would work in practice, the code snippet at the beginning of this section containing the `if` statement should generate output like this when run through your scanner:
```
IF       if
...
COLON    :
NEWLINE
INDENT
...
INTEGER  8
NEWLINE
DEDENT
```

## 4. Implement a makefile to generate your scanner

Finally, you should create a makefile to generate an executable scanner from your definition.  You should write your scanner definition in a Flex file, e.g. `scanner.l`.  C++ library code containing a scanner generated from your definition can then be created like so:
```
flex -o scanner.cpp scanner.l
```
This will generate a C++ file named `scanner.cpp`, which will contain a scanning function with the following prototype:
```
void yylex();
```

The `yylex()` function will read source code from `stdin`.  To be able to run your scanner, you should write a simple application whose `main()` function calls `yylex()`.  If your main application is written in `main.cpp`, you can compile your executable scanner program like this:
```
g++ main.cpp scanner.cpp -o scan
```

Assuming you simply call `yylex()` in your `main()` function, you can pass source code into your scanner using input redirection in your terminal, e.g.:
```
./scan < p1.py
```

You should implement a makefile to perform the above compilation steps (i.e. running `flex` and `g++`) to generate an executable scanner that can be used as above.

## Testing your scanner

There are four simple Python programs you may use for testing your scanner included in the `testing_code/` directory.  Your scanner should be able to scan all of the syntax in each of these programs.  Example output for each program is provided in the `example_output/` directory.

## Hints/guidance

Here is some guidance on how to implement your scanner:

  * Think carefully about how to write regular expressions to recognize lines that are indented and lines that are not indented.  (How do you know when a line of code *is* indented?  How do you know when a line of code *is not* indented?)  For the actions associated with these regular expressions, make sure you can measure the level of indentation.  The value `yyleng`, the length of the current token, could be helpful for this.  Figure out a mechanism for determining when indentation increases and when it decreases.  The stack-based mechanism described in [the Python documentation linked above](https://docs.python.org/3/reference/lexical_analysis.html#indentation) is a good bet here.  Feel free to use `std::stack` from the C++ standard library (or any other 3rd-party stack implementation) if you choose to go this route.

  * The `<<EOF>>` pattern can be used in a Flex rule to detect when your scanner has reached the end of the source code file.  This can be helpful for inserting any final `DEDENT` tokens that are needed at the end of the source code.

  * When your scanner definition includes multiple patterns that match a given string in the source code, Flex will choose the pattern that matches the most text.  If two patterns match the same amount of text, the one listed first in your scanner rules is used.  Being aware of these matching rules can help you formulate and organize regular expressions in your scanner definition.  For example, you'll want to make sure to place a rule for discarding whitespace *after* a rule used to measure indentation.

  * Flex allows you to define your scanner so that it can scan multiple files at once.  We don't need to worry about doing that for this assignment, so you can specify the following option in your Flex file:
    ```
    %option noyywrap
    ```

## Submission

We'll be using GitHub Classroom for this assignment, and you will submit your assignment via GitHub.  Make sure your completed files are committed and pushed by the assignment's deadline to the master branch of the GitHub repo that was created for you by GitHub Classroom.  A good way to check whether your files are safely submitted is to look at the master branch your assignment repo on the github.com website (i.e. https://github.com/osu-cs480-sp21/assignment-1-YourGitHubUsername/). If your changes show up there, you can consider your files submitted.

## Grading criteria

The TAs will grade your assignment by compiling and running it on one of the ENGR servers, e.g. `flip.engr.oregonstate.edu`, so you should make sure your code works as expected there.  `flex` is already installed on the ENGR servers.  If your code does not compile and run on the ENGR servers, the TAs will deduct at least 25 points from your score.

This assignment is worth 100 points total, broken down as follows:

  * 20 points: signed up for Campuswire

  * 80 points: implemented simplified Python scanner:
    * 50 points: scanner correctly recognizes basic syntactic categories (e.g. identifiers, numbers, keywords, operators, newlines, etc.) and generates the appropriate output for these, as described above
    * 5 points: scanner correctly ignores whitespace, blank lines, and whole-line comments
    * 20 points: scanner correctly tracks indentation and emits `INDENT` and `DEDENT` tokens when appropriate
    * 5 points: your submission includes a makefile that generates an executable scanner from your scanner definition
