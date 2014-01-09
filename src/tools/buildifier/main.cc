#include <fstream>
#include "boost/filesystem.hpp"
#include "gflags/gflags.h"
#include "tools/buildifier/app.h"
#include "util/logging.h"

using boost::filesystem::exists;
using google::ParseCommandLineFlags;
using tools::buildifier::App;

DEFINE_string(f, "CMakeLists.txt", "Path to the file to buildify");

int main(int argc, char **argv) {
  util::logging::Init(argc, argv);
  ParseCommandLineFlags(&argc, &argv, true);
  if (argc != 1) {
    std::cout << "Usage: " << argv[0] << " [-f build_file_path]" << std::endl;
    return 1;
  }
  if (!exists(FLAGS_f)) {
    std::cout << "No " << FLAGS_f << " file in this directory.";
    return 1;
  }
  App app(FLAGS_f);
  return app.Run();
}
