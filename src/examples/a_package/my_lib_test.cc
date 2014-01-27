#include "examples/a_package/my_lib.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

namespace examples {
namespace a_package {
namespace {

TEST(MyLibTest, DummyTest) { MyLib::HelloWorld(); }

class MyMock {
 public:
  MOCK_METHOD0(MyMethod, void());
};

TEST(MyLibTest, DummyTestWithMock) {
  MyMock mock;
  EXPECT_CALL(mock, MyMethod());
  mock.MyMethod();
}

}  // namespace
}  // namespace a_package
}  // namespace examples

int main(int argc, char **argv) {
  ::testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}
