# simple cmake file to install jsoncpp if not found on the system

find_package(jsoncpp QUIET CONFIG)

if (jsoncpp_FOUND)
  message(STATUS "jsoncpp CONFIG found")
  set(jsoncpp_FOUND TRUE)
  if (NOT TARGET jsoncpp::jsoncpp)
    add_library(jsoncpp::jsoncpp ALIAS jsoncpp_lib)
  endif()
  if (jsoncpp_DEBUG)
     cmake_print_properties(TARGETS jsoncpp_lib PROPERTIES LOCATION VERSION)
  endif (jsoncpp_DEBUG)
else()

    CPMAddPackage(
            NAME Jsoncpp
            URL https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz
            VERSION 1.9.5
            OPTIONS "JSONCPP_WITH_TESTS OFF"
    )
endif()

get_target_property(JSON_INC_PATH jsoncpp_lib INTERFACE_INCLUDE_DIRECTORIES)
include_directories(${JSON_INC_PATH})