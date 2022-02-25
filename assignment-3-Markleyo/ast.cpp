#include "ast.hpp"

Branch::Branch(std::string name, std::string value) {
  this->name = name;
  this->value = value;
  this->right = NULL;
  this->left = NULL;
}

Branch::Branch(std::string name, std::string value, Branch *child_node) {
  this->name = name;
  this->value = value;
  this->children = child_node->children;
  this->right = NULL;
  this->left = NULL;
  delete child_node;
}

Branch::Branch(std::string name, std::string value, Branch *left, Branch *right) {
  this->name = name;
  this->value = value;
  this->right = left;
  this->left = right;
}

void Branch::add_child(Branch* child) {
  this->children.push_back(child);
}

void Branch::add_children(Branch* temp) {
  this->children.insert(this->children.end(), temp->children.begin(), temp->children.end());
}

std::vector<Branch*> Branch::get_children() { return children; }
std::string Branch::get_name() { return name; }
std::string Branch::get_value() { return value; }
Branch* Branch::get_left() { return left; }
Branch* Branch::get_right() { return right; }

Branch::~Branch() {}
