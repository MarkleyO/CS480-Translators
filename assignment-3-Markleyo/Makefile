all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp ast.cpp 
	g++ main.cpp parser.cpp scanner.cpp ast.cpp -o parse

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp
