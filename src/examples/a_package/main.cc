#include "examples/a_package/my_lib.h"
#include "examples/other_package/my_lib.h"

int main(int argc, char **argv) {
  examples::a_package::MyLib::HelloWorld();
  examples::other_package::MyLib::HelloWorld();
  return 0;
}
