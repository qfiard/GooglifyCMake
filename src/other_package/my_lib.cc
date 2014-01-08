#include "other_package/my_lib.h"

#include <stdio.h>

namespace other_package {
namespace my_lib {

void HelloWorld() {
  printf("Hello, World from other_package!\n");
}

}  // namespace my_lib
}  // namespace other_package
