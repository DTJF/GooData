SET(SRC_BAS
  "Goo_Axis.bas"
  "Goo_Bar2d.bas"
  "Goo_Box2d.bas"
  "Goo_Curve2d.bas"
  "Goo_Data.bas"
  "Goo_Pie2d.bas"
  "Goo_Polax.bas"
  "Goo_Simplecurve2d.bas"
  CACHE FILEPATH "BASIC source files" FORCE
  )

SET(SRC_BI
  "Goo_Axis.bi"
  "Goo_Bar2d.bi"
  "Goo_Box2d.bi"
  "Goo_Curve2d.bi"
  "Goo_Data.bi"
  "Goo_Pie2d.bi"
  "Goo_Polax.bi"
  "Goo_Simplecurve2d.bi"
  CACHE FILEPATH "BASIC header files" FORCE
  )

ADD_LIBRARY(GooDatafbcode OBJECT ${SRC_BAS})
SET_TARGET_PROPERTIES(GooDatafbcode PROPERTIES
  COMPILE_FLAGS "-Wc -fPIC"
  )
ADD_Fbc_SRC_DEPS(GooDatafbcode)

GET_FILENAME_COMPONENT(fbpath ${CMAKE_Fbc_COMPILER} PATH)
INSTALL(FILES ${SRC_BI}}
  DESTINATION ${fbpath}/../include/freebasic/GooData
  COMPONENT dev
  )

MSG_LOG(">> target <all> OK!")
