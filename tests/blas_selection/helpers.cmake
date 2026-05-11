# Shared assertion helpers for blas_selection tests.
# Helpers FATAL_ERROR on failure so the enclosing `cmake -P` script exits non-zero
# and ctest records the test as failed.

function(assert_substring needle haystack ctx)
  string(FIND "${haystack}" "${needle}" idx)
  if(idx EQUAL -1)
    message(FATAL_ERROR
      "[${ctx}] expected substring not found.\n"
      "  needle:\n    ${needle}\n"
      "  haystack:\n${haystack}")
  endif()
endfunction()

function(assert_no_substring needle haystack ctx)
  string(FIND "${haystack}" "${needle}" idx)
  if(NOT idx EQUAL -1)
    message(FATAL_ERROR
      "[${ctx}] forbidden substring found.\n"
      "  needle:\n    ${needle}\n"
      "  haystack:\n${haystack}")
  endif()
endfunction()

# Run a child `cmake` configure on a fixture and capture rc/stdout/stderr.
# Usage:
#   run_child_configure(
#     FIXTURE  <path-to-fixture>
#     BUILD    <child-build-dir>
#     ARGS     <list of -D flags>
#     OUT_RC   <var>
#     OUT_LOG  <var>          # combined stdout+stderr for easier asserting
#   )
function(run_child_configure)
  set(options)
  set(oneValueArgs FIXTURE BUILD OUT_RC OUT_LOG)
  set(multiValueArgs ARGS)
  cmake_parse_arguments(RCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  file(REMOVE_RECURSE "${RCC_BUILD}")
  file(MAKE_DIRECTORY "${RCC_BUILD}")

  execute_process(
    COMMAND ${CMAKE_COMMAND} -S "${RCC_FIXTURE}" -B "${RCC_BUILD}" ${RCC_ARGS}
    RESULT_VARIABLE rc
    OUTPUT_VARIABLE out
    ERROR_VARIABLE  err
  )
  set(${RCC_OUT_RC}  "${rc}"           PARENT_SCOPE)
  set(${RCC_OUT_LOG} "${out}\n${err}"  PARENT_SCOPE)
endfunction()
