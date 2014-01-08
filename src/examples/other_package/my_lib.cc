#include "examples/other_package/my_lib.h"

#include <stdio.h>

namespace examples {
namespace other_package {

void MyLib::HelloWorld() {
  printf("Hello, World from examples::other_package::MyLib!\n");
}

} // namespace other_package
} // namespace examples
