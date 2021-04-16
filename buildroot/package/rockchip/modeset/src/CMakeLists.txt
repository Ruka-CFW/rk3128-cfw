# vim: syntax=cmake
cmake_minimum_required(VERSION 2.8.11)

PROJECT (modeset)

include_directories(.)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

if (DEFINED MODESET_SWAP_RB)
    add_definitions(-DMODESET_SWAP_RB)
endif()

ADD_DEFINITIONS(-fpermissive)
set(BOOT_SET_H
	drm_common.h
    bootanimation.h
)
add_executable(modeset
    bootanimation.cpp
	drm_common.cpp
    modeset.cpp
    )

find_package(PkgConfig)
pkg_check_modules (DRM libdrm REQUIRED)

target_include_directories(modeset PUBLIC ${DRM_INCLUDE_DIRS})

target_link_libraries(modeset jpeg pthread ${DRM_LIBRARIES})


INSTALL(TARGETS modeset RUNTIME DESTINATION bin)
