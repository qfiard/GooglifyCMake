#ifndef UTIL_ALGORITHM_H_
#define UTIL_ALGORITHM_H_

#include <functional>
#include <utility>

namespace util {
namespace algorithm {

template <class A, class B>
bool CompareFirst(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
  return p1.first < p2.first;
}

template <class A, class B>
bool CompareFirstReversed(const std::pair<A, B> &p1,
                          const std::pair<A, B> &p2) {
  return p1.first > p2.first;
}

template <class A, class B>
bool CompareSecond(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
  return p1.second < p2.second;
}

template <class A, class B>
bool CompareSecondReversed(const std::pair<A, B> &p1,
                           const std::pair<A, B> &p2) {
  return p1.second > p2.second;
}

template <class A, class B>
class FirstComparator {
 public:
  bool operator()(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
    return p1.first < p2.first;
  }
};

template <class A, class B>
class ReversedFirstComparator {
 public:
  bool operator()(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
    return p1.first > p2.first;
  }
};

template <class A, class B>
class SecondComparator {
 public:
  bool operator()(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
    return p1.second < p2.second;
  }
};

template <class A, class B>
class ReverseSecondComparator {
 public:
  bool operator()(const std::pair<A, B> &p1, const std::pair<A, B> &p2) {
    return p1.second > p2.second;
  }
};

template <class T, class Compare = std::less<T> >
class PointerComparator {
 public:
  template <class TPtr>
  bool operator()(const TPtr &p1, const TPtr &p2) {
    Compare compare;
    return compare(*p1, *p2);
  }
};

}  // namespace algorithm
}  // namespace util

#endif  // UTIL_ALGORITHM_H_
