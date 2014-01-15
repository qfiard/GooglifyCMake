#include "util/logging.h"

#include <fstream>
#include <sstream>
#include <string>
#include "boost/filesystem.hpp"
#include "gtest/gtest.h"

namespace fs = boost::filesystem;

namespace util {

/// Reads the last line of a file.
std::string GetLastLine(std::string file_path) {
  std::ifstream file(file_path);
  std::string line;
  while (std::getline(file, line)) {
  }
  return line;
}

fs::path GetFirstFileInDirectory(const fs::path &directory) {
  fs::directory_iterator end;
  for (fs::directory_iterator it(directory); it != end; ++it) return *it;
  throw "No file in directory.";
}

class LoggingTest : public testing::Test {
 public:
  static void set_log_dir(const fs::path &log_dir) { log_dir_ = log_dir; }

 protected:
  std::string GetLastLineInLog() {
    sleep(1);  // Wait for log flush.
    fs::path log_path = GetFirstFileInDirectory(log_dir_);
    return GetLastLine(log_path.string());
  }

 private:
  static fs::path log_dir_;
};

fs::path LoggingTest::log_dir_;

TEST_F(LoggingTest, DummyLog) {
  LOG(INFO) << "Test";
  EXPECT_TRUE(GetLastLineInLog().find("\"Test\"") != std::string::npos);
}

TEST_F(LoggingTest, LogDEBUG) {
  LOG(DEBUG) << "Test";
  EXPECT_TRUE(GetLastLineInLog().find("DEBUG") != std::string::npos);
}

TEST_F(LoggingTest, LogINFO) {
  LOG(INFO) << "Test";
  EXPECT_TRUE(GetLastLineInLog().find("INFO") != std::string::npos);
}

TEST_F(LoggingTest, LogWARNING) {
  LOG(WARNING) << "Test";
  EXPECT_TRUE(GetLastLineInLog().find("WARNING") != std::string::npos);
}

TEST_F(LoggingTest, LogERROR) {
  LOG(ERROR) << "Test";
  EXPECT_TRUE(GetLastLineInLog().find("ERROR") != std::string::npos);
}

typedef LoggingTest LoggingDeathTest;

TEST_F(LoggingDeathTest, LogFATAL) {
  // ASSERT_DEATH(LOG(FATAL) << "Test", "FATAL");
}

}  // namespace util

int main(int argc, char **argv) {
  fs::path log_dir = fs::unique_path("/tmp/logging_test_%%%%%%%%%%%");
  fs::create_directory(log_dir);
  util::logging::Init(argc, argv, log_dir.string());
  util::LoggingTest::set_log_dir(log_dir);
  ::testing::InitGoogleTest(&argc, argv);
  int res = RUN_ALL_TESTS();
  fs::remove_all(log_dir);
  return res;
}
