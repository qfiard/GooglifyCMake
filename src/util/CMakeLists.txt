add_subdirectory(dev)

cc_library(abi abi.h)

cc_test(abi_test abi_test.cc)
link(abi_test third_party.gtest)

cc_library(algorithm algorithm.h)

cc_library(csv csv.h csv.cc)
link(csv :logging third_party.gflags)

cc_library(date_time date_time.h date_time.cc)
link(date_time :csv :logging third_party.boost_date_time)
add_data(date_time ${BOOST_TIME_ZONE_CSV})

cc_test(date_time_test date_time_test.cc)
link(date_time_test :date_time :logging third_party.gtest)

cc_library(iterators iterators.h)

cc_library(logging logging.h logging.cc)
link(logging third_party.g2log)

cc_test(logging_test logging_test.cc)
link(logging_test :logging third_party.boost_filesystem third_party.gtest)

cc_library(ptr_set ptr_set.h)

cc_library(socket socket.h socket.cc)
link(socket :logging base.base third_party.boost_asio third_party.gflags)

java_library(socket_java Socket.java)

cc_library(streams streams.h streams.cc)

cc_library(strings strings.h strings.cc)
link(strings :logging)

cc_test(strings_test strings_test.cc)
link(strings_test :strings third_party.gtest)

cc_library(system system.h system.cc)
link(system :logging)

cc_test(system_test system_test.cc)
link(system_test :system third_party.gtest)
