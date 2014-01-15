#include "examples/a_package/my_lib.h"

#include <stdio.h>

namespace examples {
namespace a_package {

void MyLib::HelloWorld() {
  printf("Hello, World from examples::a_package::MyLib!\n");
}

}  // namespace a_package
}  // namespace examples
