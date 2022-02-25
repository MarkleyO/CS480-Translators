#include <iostream>
#include <map>

extern int yylex();

extern std::map<std::string, float> symbols;
extern std::string* program;

int main(int argc, char const *argv[]){
  if (!yylex()) {
    std::cout << "#include <iostream>\n";
    std::cout << "int main() {\n";
    std::map<std::string, float>::iterator it;
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << "double " << it->first << ";" << std::endl;
    }
    std::cout << "\n/* Begin Program */" << "\n\n";
    std::cout << *program << std::endl;
    std::cout << "/* End Program */" << "\n\n";
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << "std::cout << \"" << it->first << ": \" << " << it->first << " << std::endl;" << std::endl;
    }
    std::cout << "}" << std::endl;
    return 0;
  } else {
    std::cout << "ERROR" << std::endl;
    return 1;
  }
}
