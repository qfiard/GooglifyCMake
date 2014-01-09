// Implements a set of unique_ptr, enhanced with raw pointer access methods.

#ifndef UTIL_PTR_SET_H_
#define UTIL_PTR_SET_H_

#include <memory>
#include <unordered_set>

namespace util {

template <class T> class conditional_deleter {
 public:
  conditional_deleter() : owner_(true) {}
  explicit conditional_deleter(bool owner) : owner_(owner) {}
  void operator()(T* p) const {
    if (owner_) default_deleter_(p);
  }

 private:
  std::default_delete<T> default_deleter_;
  bool owner_;
};

template <class T>
class ptr_set
    : public std::unordered_set<std::unique_ptr<T, conditional_deleter<T> > > {
 public:
  typedef std::unordered_set<std::unique_ptr<T, conditional_deleter<T> > >
      parent_type;
  typedef typename parent_type::const_iterator const_iterator;
  typedef typename parent_type::iterator iterator;
  typedef typename parent_type::key_type key_type;
  typedef typename parent_type::size_type size_type;
  size_type erase(const T* k) { return parent_type::erase(get_weak_ptr(k)); }
  iterator find(const T* k) { return parent_type::find(get_weak_ptr(k)); }
  const_iterator find(const T* k) const {
    return parent_type::find(get_weak_ptr(k));
  }

 private:
  key_type get_weak_ptr(const T* k) {
    return key_type(const_cast<T*>(k), conditional_deleter<T>(false));
  }
};

}  // namespace util

#endif  // UTIL_PTR_SET_H_
