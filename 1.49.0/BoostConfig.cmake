#
# Copyright (C) Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
#   http://www.boost.org/LICENSE_1_0.txt
#

#
# Determine where to look for the Boost.cmake
#
if(EMSCRIPTEN)
  set(Boost_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/emscripten")
elseif(IOS)
  set(Boost_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/ios")
elseif(APPLE)
  option(USE_LIBCPP "Use libc++ compiled libs instead of libstdc++ libs on OS X" OFF)
  if(USE_LIBCPP)
    set(Boost_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/macosx-libc++")
  else()
    set(Boost_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/macosx")
  endif()
elseif(LINUX)
  set(Boost_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/linux/lib")
endif()
#
#  Include the imported targets
#
if( NOT EXISTS "${Boost_LIB_DIR}/Boost.cmake")
    set(Boost_FOUND OFF)
    return()
endif()

#
#  Various variables
#
set(Boost_VERSION "1.49.0")
set(Boost_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/include")
set(Boost_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/include"
  CACHE FILEPATH "Boost include directory")
set(Boost_LIBRARY_DIRS "${Boost_LIB_DIR}")

include("${Boost_LIBRARY_DIRS}/Boost.cmake")

if (NOT Boost_FIND_COMPONENTS)
  set(Boost_FIND_COMPONENTS ${Boost_DEFAULT_FIND_COMPONENTS})
endif()

foreach(component ${Boost_FIND_COMPONENTS})
  if( NOT TARGET boost_${component} )
    ADD_LIBRARY(boost_${component} STATIC IMPORTED)

    find_library(Boost_LIBRARY_${component}
      NAMES boost_${component}
      PATHS ${Boost_LIBRARY_DIRS}
      NO_DEFAULT_PATH
    )
    set_target_properties(boost_${component} PROPERTIES
      IMPORTED_LOCATION ${Boost_LIBRARY_${component}}
    )
    mark_as_advanced(Boost_LIBRARY_${component})
  endif()
endforeach()

set(Boost_LIBRARIES "")

foreach(component ${Boost_FIND_COMPONENTS})
  #
  # Check that it is really a target
  # 
  set(target boost_${component})
  get_target_property(p ${target} TYPE)
  if (p MATCHES "_LIBRARY$")
    list(APPEND Boost_LIBRARIES "${target}")
  endif()
endforeach()
