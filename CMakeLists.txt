cmake_minimum_required(VERSION 3.26)

project(
    advection
    VERSION 0.1
    LANGUAGES CXX
    DESCRIPTION "Advection example for feltor library"
    HOMEPAGE_URL "https://mwiesenberger.github.io/advection/comparison.html"
)

if(CCCL_THRUST_DEVICE_SYSTEM STREQUAL "CPP")
    add_compile_definitions(THRUST_DEVICE_SYSTEM=THRUST_DEVICE_SYSTEM_CPP)
elseif(CCCL_THRUST_DEVICE_SYSTEM STREQUAL "CUDA" OR CCCL_THRUST_DEVICE_SYSTEM STREQUAL "")
    enable_language(CUDA)
    # set_source_files_properties(main.cpp PROPERTIES LANGUAGE CUDA)
# elseif(CCCL_THRUST_DEVICE_SYSTEM STREQUAL "OMP")
#     find_package(OpenMP REQUIRED)
#     add_compile_definitions(THRUST_DEVICE_SYSTEM=THRUST_DEVICE_SYSTEM_OMP)
#     list(APPEND ADVECTION_EXTRA_LIBS OpenMP::OpenMP_CXX)
else()
    message(FATAL_ERROR "Unsupported CCCL_THRUST_DEVICE_SYSTEM='${CCCL_THRUST_DEVICE_SYSTEM}'. Use CPP or OMP.")
endif()

include(cmake/CPM.cmake)

## There seem to be some be some errors in the way feltor installs jsoncpp,
## so we add it as a dependency here and include the headers manually.

CPMAddPackage(
        NAME Jsoncpp
        URL https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz
        VERSION 1.9.5
        OPTIONS "JSONCPP_WITH_TESTS OFF"
)

get_target_property(JSON_INC_PATH jsoncpp_lib INTERFACE_INCLUDE_DIRECTORIES)
include_directories(${JSON_INC_PATH})


CPMAddPackage(
    NAME feltor
    GITHUB_REPOSITORY "feltor-dev/feltor"
    VERSION 8.2
    SYSTEM ON
    EXCLUDE_FROM_ALL ON
    OPTIONS "FELTOR_DG_WITH_MATRIX OFF" "FELTOR_FILE_WITH_NETCDF ON" "FELTOR_FILE_WITH_JSONCPP ON"
)

## Use C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

foreach(target IN ITEMS continuity navier_stokes plasma temp_navier_stokes temp_plasma)
    add_executable(${target} ${target}.cpp)


    target_link_libraries(${target} PRIVATE
        netcdf
        hdf5
        hdf5_hl
        jsoncpp
        feltor::dg::dg
    )
endforeach()