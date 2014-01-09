#include "util/logging.h"

#include <unistd.h>
#include <sstream>
#include "g2log/g2log.h"
#include "g2log/g2logworker.h"

namespace util {
namespace logging {

g2LogWorker &GetInstance(const std::string &log_prefix,
                         const std::string &log_directory) {
  static g2LogWorker log_worker(log_prefix, log_directory);
  return log_worker;
}

static bool is_initialized = false;

void Init(const int &argc, char **argv, const std::string &log_directory) {
  CHECK(!is_initialized) << "Logging module was already initialized.";
  g2::initializeLogging(&GetInstance(argv[0], log_directory));
  LOG(INFO) << "PID: " << getpid() << ".";
  std::stringstream command_line;
  for (int i = 0; i < argc; ++i) {
    if (i > 0) command_line << " ";
    command_line << argv[i];
  }
  LOG(INFO) << "Command line: " << command_line.str();
  is_initialized = true;
}

void Init(const std::string &name, const std::string &log_directory) {
  CHECK(!is_initialized) << "Logging module was already initialized.";
  g2::initializeLogging(&GetInstance(name, log_directory));
  LOG(INFO) << "PID: " << getpid() << ".";
  is_initialized = true;
}

}  // namespace logging
}  // namespace util
