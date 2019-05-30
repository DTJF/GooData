#SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "/usr/lib/cmake/GtkDoc/")
#INCLUDE(GtkDocConfig)
#IF(NOT GTKDOC_FOUND)
  #MSG_LOG("!! no targets <doc...> (GTKDOC_FOUND failed)")
  #RETURN()
#ENDIF()

#SET(exec_prefix "/usr")
#find_package(GtkDoc 1.25 REQUIRED)

CONFIGURE_FILE(gtkdocentities.ent.in ${CMAKE_CURRENT_BINARY_DIR}/gtkdocentities.ent @ONLY)

# list the FreeBASIC source files
SET(all_src "")
FOREACH(nam ${SRC_BI} ${SRC_BAS})
  LIST(APPEND all_src ${CMAKE_SOURCE_DIR}/src/${nam})
ENDFOREACH()

SET(doc_prefix GooData)
SET(c_src_dir ${CMAKE_CURRENT_BINARY_DIR}/c_src)
SET(build_pn ${CMAKE_CURRENT_BINARY_DIR}/${doc_prefix})
SET(xml_pn ${build_pn}-docs.xml)
SET(p_html ${CMAKE_CURRENT_BINARY_DIR}/html)

# transfer data to build directory
IF(NOT ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  SET(p_myxml ${CMAKE_CURRENT_BINARY_DIR}/MyXml)
  ADD_CUSTOM_COMMAND(OUTPUT ${p_myxml} ${p_html}
    COMMAND ${CMAKE_COMMAND} -E copy_directory MyXml ${p_myxml}
    COMMAND ${CMAKE_COMMAND} -E copy_directory html ${p_html}
    COMMAND ${CMAKE_COMMAND} -E copy ${doc_prefix}-docs.xml ${xml_pn}
    COMMENT "copying ${p_myxml} / ${p_html}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
ENDIF()

# compile the object scanner binary
SET(scan_bas ${CMAKE_CURRENT_SOURCE_DIR}/${doc_prefix}-scan.bas)
SET(scan_exe ${build_pn}-scan)
ADD_CUSTOM_COMMAND(OUTPUT ${scan_exe}
  COMMAND ${CMAKE_Fbc_COMPILER} -w all -x ${scan_exe} ${scan_bas}
  COMMENT "compiling ${scan_exe}"
  DEPENDS
    ${all_src}
    ${scan_bas}
    ${CMAKE_CURRENT_SOURCE_DIR}/gtk-doc-scan.bas
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

# run the object scanner binary
SET(pn_sign ${build_pn}.signals)
SET(pn_hier ${build_pn}.hierarchy)
SET(pn_intf ${build_pn}.interfaces)
SET(pn_prer ${build_pn}.prerequisites)
SET(pn_args ${build_pn}.args)
ADD_CUSTOM_COMMAND(OUTPUT
    ${pn_sign}
    ${pn_hier}
    ${pn_intf}
    ${pn_prer}
    ${pn_args}
  COMMAND ${scan_exe}
  DEPENDS ${scan_exe}
  COMMENT "running ${scan_exe}"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )

# run fbdoc to generate the C source
ADD_CUSTOM_COMMAND(OUTPUT ${c_src_dir}
  COMMAND fbdoc -f -a -c -o ${c_src_dir}
  DEPENDS ${all_src}
  COMMENT "transformin FB -> C"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
  )

# run gtk-doc scripts
SET(com_flg --module=${doc_prefix} --source-dir=${c_src_dir})
SET(decl_list ${build_pn}-decl-list.txt)
ADD_CUSTOM_COMMAND(OUTPUT ${decl_list}
  COMMAND /usr/bin/gtkdoc-scan ${com_flg} --rebuild-sections --rebuild-types
  COMMAND /usr/bin/gtkdoc-mkdb ${com_flg} --output-format=xml --main-sgml-file=${xml_pn}
  COMMAND ${CMAKE_COMMAND} -E copy_if_different gtkdocentities.ent xml
  COMMAND cd html && /usr/bin/gtkdoc-mkhtml ${doc_prefix} ${xml_pn}
  COMMAND /usr/bin/gtkdoc-fixxref --module=${doc_prefix} --module-dir=./html ${_fixxref_opts}
  DEPENDS
    ${c_src_dir}
    ${decl_list}
    ${all_src}
    ${scan_exe}
    ${pn_sign}
    ${pn_hier}
    ${pn_intf}
    ${pn_prer}
    ${pn_args}
    ${p_html}
  COMMENT "performin gtk-doc"
  )

## Create the doc-libGooData target.
#gtk_doc_add_module(GooData
  #SOURCE ${c_src_dir}
  #XML GooData-docs.xml
  ##LIBRARIES GooData
#)

# Build doc-libmeep as part of the default target. Without this, you would
# have to explicitly run something like `make doc-libmeep` to build the docs.
#add_custom_target(doc DEPENDS doc-GooData ${decl_list})
add_custom_target(doc DEPENDS ${decl_list})

# Install the docs. (This assumes you're using the GNUInstallDirs CMake module
# to set the CMAKE_INSTALL_DOCDIR variable correctly).
#install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html
        #DESTINATION ${CMAKE_INSTALL_DOCDIR})

MSG_LOG(">> target <doc> OK!")
