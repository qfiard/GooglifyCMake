#include "util/strings.h"
#include "gtest/gtest.h"

namespace util {
namespace strings {
namespace {

TEST(StringsUtil, Join) {
  EXPECT_EQ("a,b,c", Join({
    "a", "b", "c"
  },
                          ","));
}

TEST(StringsUtil, Strip) { EXPECT_EQ("abc", Trim("  \tabc \t\n", " \t\n")); }

TEST(StringsUtil, Split) {
  EXPECT_EQ(std::vector<std::string>({
    "a", "b", "c"
  }),
            Split(" a b\tc", " \t\n"));
}

TEST(StringsUtil, SplitBug1) {
  EXPECT_EQ(std::vector<std::string>({
    "a", "b", "c"
  }),
            Split("a b c"));
}

TEST(StringsUtil, SplitBug2) {
  EXPECT_EQ(std::vector<std::string>({
    "set.int32"
  }),
            Split("set.int32"));
}

TEST(StringsUtil, SplitWithQuotedElement) {
  EXPECT_EQ(std::vector<std::string>({
    "a", "b", "c d"
  }),
            Split("a b \"c d\""));
}

TEST(StringsUtil, SplitWithInnerQuotes) {
  EXPECT_EQ(std::vector<std::string>({
    "a", "bc d", "e"
  }),
            Split("a b\"c d\" e"));
}

}  // namespace
}  // namespace strings
}  // namespace util

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
