#include "util/date_time.h"
#include "boost/date_time/gregorian/gregorian.hpp"
#include "gtest/gtest.h"
#include "util/logging.h"

namespace util {
namespace date_time {
namespace {

using boost::gregorian::date;
using boost::gregorian::Dec;
using boost::gregorian::Feb;
using boost::gregorian::Jan;
using boost::posix_time::time_duration;

TEST(DateTime, DateToString) {
  DateTime d(date(2001, Dec, 31), time_duration(1, 2, 3));
  EXPECT_EQ("20011231T010203", DateToString(d));
}

TEST(DateTime, ParseDateString) {
  std::string to_parse = "2001-12-31 01:02:03";
  EXPECT_EQ(DateTime(date(2001, Dec, 31), time_duration(1, 2, 3)),
            ISO9075StringToDate(to_parse));
}

TEST(DateTime, DateFromTimeIntervalSinceReference) {
  EXPECT_EQ(DateTime(date(2002, Feb, 2), time_duration(1, 2, 3)),
            DateFromTimeIntervalSinceReference(31536000. + 2678400. + 86400. +
                                               3600. + 120. + 3.));
}

TEST(DateTime, SecondsBetweenDates) {
  DateTime d1(date(2001, Jan, 1), time_duration());
  DateTime d2(date(2002, Feb, 2), time_duration(1, 2, 3));
  double offset = 31536000. + 2678400. + 86400. + 3600. + 120. + 3.;
  EXPECT_EQ(offset, SecondsBetweenDates(d1, d2));
  EXPECT_EQ(-offset, SecondsBetweenDates(d2, d1));
}

TEST(DateTime, GetUTCOffsetForTimezoneAbbr) {
  TimeDuration offset;
  EXPECT_TRUE(GetUTCOffsetForTimezoneAbbr("PST", &offset));
  EXPECT_EQ(-8 * 3600, offset.total_seconds());
}

}  // namespace
}  // namespace date_time
}  // namespace util

int main(int argc, char **argv) {
  util::logging::Init(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
