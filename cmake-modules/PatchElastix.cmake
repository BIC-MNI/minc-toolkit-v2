# PatchElastix.cmake — Patch Elastix CMakeLists.txt for CMake >= 3.28 compatibility
# - Adds cmake_minimum_required() before any cmake_policy() calls
# - Removes export_library_dependencies() which is gone in CMake 3.28+
#
# Expects -DSOURCE_DIR=<path to Elastix source>

set(CMAKELISTS "${SOURCE_DIR}/CMakeLists.txt")
file(READ "${CMAKELISTS}" CONTENT)

# 1. Add cmake_minimum_required at the very top if not already present
if(NOT CONTENT MATCHES "cmake_minimum_required")
  string(REPLACE
    "#---------------------------------------------------------------------\ncmake_policy( SET CMP0012 NEW )"
    "cmake_minimum_required(VERSION 2.8.12)\n#---------------------------------------------------------------------\ncmake_policy( SET CMP0012 NEW )"
    CONTENT "${CONTENT}")
endif()

# 2. Replace export_library_dependencies() with a comment
string(REPLACE
  "export_library_dependencies( \${elxLIBRARY_DEPENDS_FILE} )"
  "# export_library_dependencies removed (CMP0033, CMake >= 3.28)"
  CONTENT "${CONTENT}")

# 3. CMake 4.x no longer supports setting these policies to OLD. Use NEW:
#    CMP0033 NEW is safe (export_library_dependencies already removed above),
#    and CMP0007 defaults to NEW anyway given cmake_minimum_required(3.10).
string(REPLACE
  "cmake_policy( SET CMP0033 OLD )"
  "cmake_policy( SET CMP0033 NEW )"
  CONTENT "${CONTENT}")
string(REPLACE
  "cmake_policy( SET CMP0007 OLD )"
  "cmake_policy( SET CMP0007 NEW )"
  CONTENT "${CONTENT}")

file(WRITE "${CMAKELISTS}" "${CONTENT}")
message(STATUS "Patched Elastix CMakeLists.txt for CMake 3.28+ compatibility")
