#include <iostream>
#include <set>
#include "parser.hpp"

extern int yylex();
extern Branch *seed;

using namespace std;
/*
 * These values are globals defined in the parsing function.
 */
//extern std::string* target_program;
//extern std::set<std::string> symbols;

int main() {
  if (!yylex()) {
    std::cout << "digraph G {" << std::endl;
    std::cout << seed->get_name() << std::endl;

    int level = 0;
    Branch *current_head = seed;
    int entry_count = 0;
    vector <Branch *> entries; 
    entries.clear();
    do{
      cout << "Current Head: " << current_head->get_name() << " "  << current_head->get_value()
        << " " << current_head->get_children().size() << " " << current_head->get_left() << " " << current_head->get_right() << endl;
      cout << (current_head->get_right() == 0) << endl;
      int entries_on_level = current_head->get_children().size();

      if (entries_on_level > 0) {
        for ( int i = 0; i < entries_on_level; i ++ ) {
          entries.push_back(current_head->get_children()[i]);
          cout << current_head->get_children()[i]->get_name() << endl;
        }
      } else if (!((current_head->get_right() == 0)
          && (current_head->get_left() == 0)
          && (current_head->get_children().size() == 0)))
      {
        entries.push_back(current_head->get_left());
        cout << current_head->get_left()->get_name() << endl;
        entries.push_back(current_head->get_right());
        cout << current_head->get_right()->get_name() << endl;
      }
      cout << endl;

      current_head = entries[entry_count];
      entry_count ++;
      level ++;
    }
    while ( level < 20 );
    
    
  }
}
