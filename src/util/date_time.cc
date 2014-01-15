#include "util/date_time.h"

#include <math.h>
#include <ctime>
#include <iostream>
#include <fstream>
#include <locale>
#include <sstream>
#include <unordered_map>
#include <vector>
#include "boost/date_time.hpp"
#include "boost/functional/hash.hpp"
#include "util/csv.h"
#include "util/logging.h"

namespace util {
namespace date_time {

namespace bl = boost::local_time;
namespace bt = boost::posix_time;
using boost::gregorian::date;
using bt::microsec_clock;
using bt::ptime_from_tm;
using bt::time_input_facet;
using bt::to_iso_string;

std::string DateToString(const DateTime &date) {
  std::string res(to_iso_string(date));
  // Removing microseconds
  std::string::size_type loc = res.find(".");
  if (loc != std::string::npos) {
    res = res.substr(0, loc);
  }
  return res;
}

static std::unordered_map<std::string, TimeDuration>
    utc_offset_for_timezone_abbr;

const std::unordered_map<std::size_t, std::size_t> kOffsetFieldForField = {
    {1, 5}, {3, 6}};

static void InitUTCOffsetForTimezoneAbbr() {
  std::ifstream date_time_zonespec("date_time_zonespec.csv");
  std::string line;
  std::getline(date_time_zonespec, line);  // Skipping header.
  std::unordered_map<std::string, std::unordered_map<TimeDuration, uint32_t,
                                                     TimeDurationHash> > counts;
  while (std::getline(date_time_zonespec, line)) {
    const std::vector<std::string> &fields = csv::Parse(line);
    const std::string &std_abbr = fields[1];
    TimeDuration std_offset = bt::duration_from_string(fields[5]);
    counts[std_abbr][std_offset]++;
    const std::string &dst_abbr = fields[3];
    if (!dst_abbr.empty()) {
      TimeDuration dst_offset =
          std_offset + bt::duration_from_string(fields[6]);
      counts[dst_abbr][dst_offset]++;
    }
  }
  for (const auto &abbr_count : counts) {
    uint32_t max = 0;
    for (const auto &pair : abbr_count.second) {
      if (pair.second > max) {
        max = pair.second;
        utc_offset_for_timezone_abbr[abbr_count.first] = pair.first;
      }
    }
  }
}

bool GetUTCOffsetForTimezoneAbbr(const std::string &abbr,
                                 TimeDuration *offset) {
  if (utc_offset_for_timezone_abbr.empty()) {
    InitUTCOffsetForTimezoneAbbr();
  }
  if (utc_offset_for_timezone_abbr.find(abbr) ==
      utc_offset_for_timezone_abbr.end()) {
    return false;
  }
  *offset = utc_offset_for_timezone_abbr[abbr];
  return true;
}

DateTime ISO9075StringToDate(const std::string s) {
  std::stringstream date_stream(s);
  std::string format("%Y-%m-%d %H:%M:%S");
  auto &date_parser = std::use_facet<std::time_get<char> >(std::locale());
  std::tm parsed_date;
  std::ios::iostate state;
  date_parser.get(date_stream, std::time_get<char>::iter_type(), date_stream,
                  state, &parsed_date, format.data(),
                  format.data() + format.length());
  return ptime_from_tm(parsed_date);
}

DateTime Now() { return microsec_clock::universal_time(); }

DateTime DateFromTimeIntervalSinceReference(double timeInterval) {
  DateTime res(date(2001, 1, 1));
  int64_t hours = floor(timeInterval / 3600);
  timeInterval -= 3600 * hours;
  int64_t minutes = floor(timeInterval / 60);
  timeInterval -= 60 * minutes;
  int64_t seconds = floor(timeInterval);
  timeInterval -= seconds;
  int64_t microseconds = round(1e6 * timeInterval);
  TimeDuration delta(hours, minutes, seconds, microseconds);
  return res + delta;
}

double SecondsBetweenDates(DateTime start, DateTime end) {
  return ((double)(end - start).total_microseconds()) / 1e6;
}

std::size_t TimeDurationHash::operator()(TimeDuration const &td) const {
  return std::hash<uint64_t>()(td.ticks());
}

}  // namespace date_time
}  // namespace util
