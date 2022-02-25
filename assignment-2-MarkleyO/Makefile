all: parse

parse: main.cpp scanner.cpp parser.cpp
	g++ main.cpp scanner.cpp parser.cpp -o parse

parser.cpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l


clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp
