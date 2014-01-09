#ifndef BASE_SIGNAL_HANDLER_H_
#define BASE_SIGNAL_HANDLER_H_

#include <functional>
#include <unordered_map>
#include "base/base.h"

namespace base {

class SignalHandler {
 public:
  typedef std::function<void()> Callback;
  static void RegisterCallback(int sig, const Callback& callback);

 private:
  SignalHandler() {}
  static SignalHandler& GetInstance();
  friend void HandleSignal(int sig);

  std::unordered_map<int, std::function<void()> > signal_callbacks_;

  DISALLOW_COPY_AND_ASSIGN(SignalHandler);
};

}  // namespace base

#endif  // BASE_SIGNAL_HANDLER_H_
