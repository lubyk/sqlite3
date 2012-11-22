# --------------------------------------------------------------
#  xml_vendor
#  
#  expects:
#    MODULE_NAME defined in the CMakeLists for the module
#
#  provides:
#    xml/vendor.so
#    LuaXml.lua
# --------------------------------------------------------------

include_directories(sqlite3)
set(SOURCES LuaSQLite/lsqlite3.c sqlite3/sqlite3.c)

if(MODULES_STATIC)
  set(target "${MODULE_NAME}_static")
  add_library(${target} ${SOURCES})
else(MODULES_STATIC)
  set(target "${MODULE_NAME}_vendor")
  add_library(${target} MODULE ${SOURCES})
  set_target_properties(${target}
    PROPERTIES OUTPUT_NAME vendor
    LINK_FLAGS ${PLAT_OBJ_FLAGS}
    PREFIX ""
    SUFFIX ".so"
  )  

  # --------------------------------------------------------------
  #  only install .so
  # --------------------------------------------------------------
  install(TARGETS ${target}
    DESTINATION ${LUBYK_LIB}/lib/${MODULE_NAME}
  )
endif(MODULES_STATIC)

add_dependencies(${MODULE_NAME} ${target})

if(LINUX)
  target_link_libraries(${target} -lpthread)
endif(LINUX)
