cmake_minimum_required(VERSION 3.26)

project(
    advection
    VERSION 1.0
    LANGUAGES CXX
    DESCRIPTION "Advection examples for feltor library"
    HOMEPAGE_URL "https://mwiesenberger.github.io/advection/comparison.html"
)

if(CCCL_THRUST_DEVICE_SYSTEM STREQUAL "CPP")
    add_compile_definitions(THRUST_DEVICE_SYSTEM=THRUST_DEVICE_SYSTEM_CPP)
else()
    message(FATAL_ERROR "Unsupported CCCL_THRUST_DEVICE_SYSTEM='${CCCL_THRUST_DEVICE_SYSTEM}'. Use CPP or OMP.")
endif()

include(cmake/CPM.cmake)

## There seem to be some be some errors in the way feltor installs jsoncpp,
## so we add it as a dependency here and include the headers manually.
include(cmake/InstallJSONCPP.cmake)

find_package(netCDF CONFIG REQUIRED)
find_package(hdf5 CONFIG REQUIRED)

CPMAddPackage(
    NAME feltor
    GITHUB_REPOSITORY "feltor-dev/feltor"
    VERSION 8.2
    SYSTEM ON
    EXCLUDE_FROM_ALL ON
    OPTIONS "FELTOR_DG_WITH_MATRIX OFF" "FELTOR_FILE_WITH_NETCDF ON" "FELTOR_FILE_WITH_JSONCPP ON"
)

## Use C++17 standard
if(CCCL_THRUST_DEVICE_SYSTEM STREQUAL "CPP")
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(MSVC)
    set(HDF5_LIBRARIES hdf5::hdf5-shared hdf5::hdf5_hl-shared)
else()
    set(HDF5_LIBRARIES hdf5 hdf5_hl)
endif()

foreach(target IN ITEMS continuity navier_stokes plasma temp_navier_stokes temp_plasma)
    add_executable(${target} ${target}.cpp)

    target_link_libraries(${target} PRIVATE
        netCDF::netcdf
        ${HDF5_LIBRARIES}
        jsoncpp_lib
        feltor::dg::dg
    )

endforeach()