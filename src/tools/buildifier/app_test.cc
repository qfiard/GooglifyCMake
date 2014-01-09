#include "tools/buildifier/app.h"

#include <fstream>
#include <unordered_map>
#include "gtest/gtest.h"
#include "util/logging.h"

namespace tools {
namespace buildifier {
namespace {

class AppTest : public ::testing::Test {
 protected:
  void BackupFile(const std::string &file_path);
  void GetFileContents(const std::string &file_path,
                       std::string *contents) const;
  void RestoreFile(const std::string &file_path) const;
  void TestBuildFile(const std::string &file_path);

 private:
  std::unordered_map<std::string, std::string> file_backups_;
};

void AppTest::BackupFile(const std::string &file_path) {
  GetFileContents(file_path, &file_backups_[file_path]);
}

void AppTest::GetFileContents(const std::string &file_path,
                              std::string *contents) const {
  std::ifstream file(file_path, std::ios::binary);
  file.seekg(0, std::ios::end);
  contents->resize(file.tellg());
  file.seekg(0, std::ios::beg);
  file.read((char *)contents->data(), contents->size());
}

void AppTest::RestoreFile(const std::string &file_path) const {
  CHECK(file_backups_.find(file_path) != file_backups_.end())
      << "File " << file_path << " was not backed up.";
  std::ofstream file(file_path, std::ios::binary);
  file.write(file_backups_.find(file_path)->second.data(),
             file_backups_.find(file_path)->second.size());
}

void AppTest::TestBuildFile(const std::string &file_path) {
  BackupFile(file_path);
  std::string expected;
  GetFileContents(file_path, &expected);
  App app(file_path);
  EXPECT_EQ(0, app.Run());
  std::string actual;
  GetFileContents(file_path, &actual);
  EXPECT_EQ(expected, actual);
  RestoreFile(file_path);
}

TEST_F(AppTest, ParseCMakeLists1) { TestBuildFile("testdata/CMakeLists1.txt"); }

TEST_F(AppTest, ParseCMakeLists2) { TestBuildFile("testdata/CMakeLists2.txt"); }

}  // namespace
}  // namespace buildifier
}  // namespace tools

int main(int argc, char **argv) {
  util::logging::Init(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
