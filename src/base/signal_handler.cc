#include "base/signal_handler.h"

#include <signal.h>
#include <iostream>

namespace base {

SignalHandler& SignalHandler::GetInstance() {
  static SignalHandler signal_handler;
  return signal_handler;
}

void HandleSignal(int sig) {
  SignalHandler::GetInstance().signal_callbacks_[sig]();
}

void SignalHandler::RegisterCallback(int sig, const Callback& callback) {
  GetInstance().signal_callbacks_[sig] = callback;
  // Cannot use CHECK because this is a base class.
  if (signal(SIGINT, &HandleSignal) == SIG_ERR) {
    std::cerr << "Failed to register signal handler for signal " << sig
              << ".\n";
    exit(1);
  }
}

}  // namespace base
