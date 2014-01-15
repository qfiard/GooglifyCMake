#ifndef UTIL_ITERATORS_H_
#define UTIL_ITERATORS_H_

#include <string>
#include <utility>

namespace util {
namespace iterators {

template <class Container>
class ConstPairIterator {
 public:
  ConstPairIterator(const typename Container::const_iterator &it)
      : pair_iterator_(it) {}
  ConstPairIterator(const ConstPairIterator<Container> &it)
      : pair_iterator_(it.pair_iterator_) {}
  ConstPairIterator<Container> &operator=(
      const ConstPairIterator<Container> &it) {
    pair_iterator_ = it.pair_iterator_;
    return *this;
  }
  ConstPairIterator<Container> &operator++() {
    ++pair_iterator_;
    return *this;
  }
  ConstPairIterator<Container> operator++(int) {
    auto res = *this;
    ++pair_iterator_;
    return res;
  }

  const typename Container::const_iterator &pair_iterator() const {
    return pair_iterator_;
  }
  typename Container::const_iterator &pair_iterator() { return pair_iterator_; }

 private:
  typename Container::const_iterator pair_iterator_;
};

template <class Container>
class ConstFirstIterator : public ConstPairIterator<Container> {
 public:
  using ConstPairIterator<Container>::ConstPairIterator;
  using ConstPairIterator<Container>::pair_iterator;
  const typename Container::value_type::first_type &operator*() {
    return pair_iterator()->first;
  }
  const typename Container::value_type::first_type *operator->() {
    return &(pair_iterator()->first);
  }
};

template <class Container>
class ConstSecondIterator : public ConstPairIterator<Container> {
 public:
  using ConstPairIterator<Container>::ConstPairIterator;
  using ConstPairIterator<Container>::pair_iterator;
  const typename Container::value_type::second_type &operator*() {
    return pair_iterator()->second;
  }
  const typename Container::value_type::second_type *operator->() {
    return &(pair_iterator()->second);
  }
};

template <class Container>
void swap(ConstPairIterator<Container> &it1,
          ConstPairIterator<Container> &it2) {
  swap(it1.pair_iterator(), it2.pair_iterator());
}

template <class Container>
bool operator==(const ConstPairIterator<Container> &it1,
                const ConstPairIterator<Container> &it2) {
  return it1.pair_iterator() == it2.pair_iterator();
}

template <class Container>
bool operator!=(const ConstPairIterator<Container> &it1,
                const ConstPairIterator<Container> &it2) {
  return it1.pair_iterator() != it2.pair_iterator();
}

}  // namespace iterators
}  // namespace util

#endif  // UTIL_ITERATORS_H_
