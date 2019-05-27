#SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "/usr/lib/cmake/GtkDoc/")
#INCLUDE(GtkDocConfig)
#IF(NOT GTKDOC_FOUND)
  #MSG_LOG("!! no targets <doc...> (GTKDOC_FOUND failed)")
  #RETURN()
#ENDIF()

#SET(exec_prefix "/usr")
#find_package(GtkDoc 1.25 REQUIRED)

SET(fbdoc_lfn "${CMAKE_CURRENT_BINARY_DIR}/fbdoc.lfn")
SET(c_src_dir ${CMAKE_CURRENT_BINARY_DIR}/c_src)
ADD_CUSTOM_COMMAND(OUTPUT ${fbdoc_lfn}
  COMMAND fbdoc -f -a -c -o ${c_src_dir}
  COMMENT "transformin FB -> C"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
  )


SET(doc_prefix GooData)
SET(scan_exe ${CMAKE_CURRENT_BINARY_DIR}/${doc_prefix}-scan)
ADD_CUSTOM_COMMAND(OUTPUT ${scan_exe}
  COMMAND ${CMAKE_Fbc_COMPILER} -w all -x ${scan_exe} GooData-scan.bas
  COMMAND ${scan_exe}
  COMMENT "compiling/running ${scan_exe}"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

#SET(xml_pn ${CMAKE_CURRENT_SOURCE_DIR}/GooData-docs.xml)
SET(xml_pn ${CMAKE_CURRENT_BINARY_DIR}/GooData-docs.xml)
SET(com_flg --module=${doc_prefix} --source-dir=${c_src_dir})
SET(decl_list "${CMAKE_CURRENT_BINARY_DIR}/${PROJ_NAME}-decl-list.txt")
ADD_CUSTOM_COMMAND(OUTPUT ${decl_list}
  COMMAND /usr/bin/gtkdoc-scan ${com_flg} --rebuild-sections --rebuild-types
  COMMAND /usr/bin/gtkdoc-mkdb ${com_flg} --output-format=xml --main-sgml-file=${xml_pn} --source-suffixes=h,c
            #--source-suffixes=${_doc_source_suffixes}
  COMMAND cd html && /usr/bin/gtkdoc-mkhtml ${doc_prefix} ${xml_pn}
  #COMMAND /usr/bin/gtkdoc-mkhtml --module=${doc_prefix}
  DEPENDS ${fbdoc_lfn} ${scan_exe}
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
