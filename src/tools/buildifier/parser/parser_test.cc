#include "tools/buildifier/parser/parser.h"
#include "tools/buildifier/parser/processor.h"
#include "tools/buildifier/parser/scanner.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "util/logging.h"

namespace tools {
namespace buildifier {
namespace parser {
namespace {

class ProcessorMock : public Processor {
 public:
  MOCK_METHOD2(AddCommand,
               bool(const std::string &, const std::vector<std::string> &));
};

class ParserTest : public ::testing::Test {
 protected:
  ProcessorMock processor_mock_;
};

TEST_F(ParserTest, SimpleBuildFile) {
  std::stringstream build_file;
  build_file << "cc_library(a a.h a.cc)\n"
                "link(a :b)\n"
                "\n"
                "cc_library(b b.h b.cc)\n"
                "link(b util.logging)\n";
  Scanner scanner(&build_file);
  Parser parser(&scanner, &processor_mock_);
  EXPECT_EQ(0, parser.parse());
}

}  // namespace
}  // namespace parser
}  // namespace buildifier
}  // namespace tools

int main(int argc, char **argv) {
  util::logging::Init(argc, argv);
  ::testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}
