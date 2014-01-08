#include "a_package/my_lib.h"
#include "other_package/my_lib.h"

using a_package::my_lib::HelloWorld;

int main(int argc, char **argv) {
  HelloWorld();
  other_package::my_lib::HelloWorld();
  return 0;
}
