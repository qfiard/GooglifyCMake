#ifndef UTIL_DATE_TIME_H_
#define UTIL_DATE_TIME_H_

#include <string>
#include "boost/date_time/posix_time/posix_time.hpp"

namespace util {
namespace date_time {

typedef boost::posix_time::ptime DateTime;
typedef boost::posix_time::time_duration TimeDuration;

std::string DateToString(const DateTime& date);
bool GetUTCOffsetForTimezoneAbbr(const std::string& abbr, TimeDuration* offset);
DateTime ISO9075StringToDate(const std::string s);
DateTime Now();
DateTime DateFromTimeIntervalSinceReference(double seconds);
double SecondsBetweenDates(DateTime start, DateTime end);

class TimeDurationHash {
 public:
  std::size_t operator()(TimeDuration const& td) const;
};

}  // namespace date_time
}  // namespace util

#endif
