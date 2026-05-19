cmake_minimum_required(VERSION 3.26)

project(
    advection
    VERSION 1.0
    LANGUAGES CXX
    DESCRIPTION "Advection examples for feltor library"
    HOMEPAGE_URL "https://mwiesenberger.github.io/advection/comparison.html"
)

set( CCCL_THRUST_DEVICE_SYSTEM "CPP")

include(cmake/CPM.cmake)

CPMAddPackage(
    NAME feltor
    GITHUB_REPOSITORY "feltor-dev/feltor"
    VERSION 8.2
    SYSTEM ON
    EXCLUDE_FROM_ALL ON
    OPTIONS "FELTOR_DG_WITH_MATRIX OFF" "FELTOR_FILE_WITH_NETCDF ON"
)


foreach(target IN ITEMS continuity navier_stokes plasma temp_navier_stokes temp_plasma)

    add_executable(${target} ${target}.cpp)
    
    ## Force use of C++17 and disable compiler extensions for all targets
    set_target_properties(${target} PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
    
    target_sources(${target} PRIVATE common.h)
    
    target_link_libraries(${target} PRIVATE
    feltor::dg::file
    feltor::dg::dg
    )

endforeach()