#include "util/abi.h"
#include "gtest/gtest.h"

namespace util {
namespace abi {

class ABC {};

namespace {

TEST(ABITest, ClassTest) {
  ABC abc;
  EXPECT_EQ("util::abi::ABC", GetDemangledType(abc));
}

}  // namespace
}  // namespace abi
}  // namespace util

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
