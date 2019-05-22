CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
SET(CMAKE_VERBOSE_MAKEFILE 1)

# constants
SET(PROJ_NAME "libpruio" CACHE STRING "project name" FORCE)
SET(PROJ_DESC "Fast and easy Input/Output for digital/analog on Beagleboard" CACHE STRING "project description" FORCE)
SET(PROJ_VERS "0.0.2"   CACHE STRING "project version" FORCE)
SET(PROJ_AUTH "DTJF"    CACHE STRING "project authors" FORCE)
SET(PROJ_MAIL "Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net"  CACHE STRING "project mail address" FORCE)
SET(PROJ_WEBS "https://github.com/DTJF/goo_data" CACHE STRING "project website" FORCE)
SET(PROJ_LICE "LGPLv2.1" CACHE STRING "project licence" FORCE)
#STRING(TIMESTAMP tmp "%Y" UTC) # requires CMake 2.8.11
#SET(PROJ_YEAR "${tmp}"             CACHE STRING "project year" FORCE)
SET(PROJ_YEAR "2019"   CACHE STRING "project year" FORCE)

PROJECT(${PROJ_NAME} Fbc)

FUNCTION(MSG_LOG Txt)
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log "${Txt}\n\n")
  MESSAGE(STATUS ${Txt})
ENDFUNCTION()

IF(NOT CMAKE_Fbc_COMPILER_WORKS)
  MSG_LOG("!! no targets <all> <examples> (fbc compiler problem)")
  RETURN()
ENDIF()

ADD_SUBDIRECTORY(src)

ADD_LIBRARY(goodata SHARED $<TARGET_OBJECTS:GooDatafbcode>)
ADD_DEPENDENCIES(goodata GooDatafbcode)
SET_TARGET_PROPERTIES(goodata PROPERTIES
  LINK_FLAGS "-Wl -z,relro"
  SOVERSION "o" # adapt <Package: ...> in debian/control
  #NO_SONAME "YES"
  )
INSTALL(TARGETS goodata
  #LIBRARY DESTINATION lib/${PROJ_NAME}-${PROJ_VERS}
  LIBRARY DESTINATION lib/
  COMPONENT bin
  )
