#ifndef AST
#define AST

#include <vector>
#include <string>

class Branch {
private:
  std::string name;
  std::string value;
  std::vector<Branch *> children;
  Branch *left;
  Branch *right;

public:
  Branch(std::string name, std::string value);
  Branch(std::string name, std::string value, Branch *child_node);
  Branch(std::string name, std::string value, Branch *left, Branch *right);
  void add_child(Branch *child);
  void add_children(Branch *temp);
  std::vector<Branch *> get_children();
  std::string get_name();
  std::string get_value();
  Branch* get_left();
  Branch* get_right();
  ~Branch();
};


#endif
