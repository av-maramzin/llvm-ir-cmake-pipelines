#.rst:
#LLVM-IR-Pipelines
# -------------
#
# LLVM IR pipelines for cmake

cmake_minimum_required(VERSION 3.2)

set(_MOD_NAME "LLVM IR Pipelines")

include(CMakeParseArguments)

include(${CMAKE_CURRENT_LIST_DIR}/internal/LLVMIRPipelinesGenerators.cmake)

set(_THIS_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(llvmir_pipelines_setup)
  set(options)
  set(oneValueArgs DEPENDS OUTPUT_FILE)
  set(multiValueArgs)
  cmake_parse_arguments(LPS
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  message(STATUS "Setting up ${_MOD_NAME}")

  if(NOT LPS_DEPENDS)
    message(FATAL_ERROR "${_MOD_NAME}: Setup command is missing DEPENDS option")
  endif()

  if(NOT LPS_OUTPUT_FILE)
    message(FATAL_ERROR "${_MOD_NAME}: Setup command is missing OUTPUT_FILE \
    option")
  endif()

  if(NOT LLVMIR_PIPELINES_TO_INCLUDE)
    message(WARNING "${_MOD_NAME}: No pipelines to be included using variable: \
    LLVMIR_PIPELINES_TO_INCLUDE")
  endif()

  if(NOT LLVMIR_PIPELINES_COMPOUND)
    message(WARNING "${_MOD_NAME}: No compound pipelines specified using \
    variable: LLVMIR_PIPELINES_COMPOUND")
  endif()

  if(LLVMIR_PIPELINES_TO_INCLUDE)
    set(PIPELINE_FILES "${LLVMIR_PIPELINES_TO_INCLUDE}")
    string(TOUPPER "${PIPELINE_FILES}" PIPELINE_FILES_UPPER)

    list(APPEND CMAKE_MODULE_PATH "${_THIS_LIST_DIR}/pipelines/")
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

    if("ALL" STREQUAL "${PIPELINE_FILES_UPPER}")
      file(GLOB PIPELINE_FILES
        RELATIVE "${_THIS_LIST_DIR}/pipelines/"
        "${_THIS_LIST_DIR}/pipelines/*.cmake")
    endif()

    foreach(FILE ${PIPELINE_FILES})
      message(STATUS "${_MOD_NAME}: Including pipeline: ${FILE}")

      include("${FILE}")
    endforeach()
  endif()

  #

  if(LLVMIR_PIPELINES_COMPOUND)
    list(LENGTH LLVMIR_PIPELINES_COMPOUND LEN)
    if(LEN GREATER 1)
      message(FATAL_ERROR "${_MOD_NAME}: More than 1 compound pipelines are \
      not supported")
    endif()

    set(PIPELINE_FILES_DIR "${CMAKE_CURRENT_BINARY_DIR}/pipelines/")
    file(MAKE_DIRECTORY "${PIPELINE_FILES_DIR}")

    list(APPEND CMAKE_MODULE_PATH "${PIPELINE_FILES_DIR}")
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

    foreach(CPLINE ${LLVMIR_PIPELINES_COMPOUND})
      string(TOUPPER "${CPLINE}" CPLINE_UC)
      set(CPLINE_PARTS "LLVMIR_PIPELINES_COMPOUND_${CPLINE_UC}")

      if(NOT DEFINED ${CPLINE_PARTS})
        message(FATAL_ERROR "${_MOD_NAME}: Pipeline ${CPLINE_PARTS} is not \
        defined!")
      endif()

      set(CPLINE_PARTS_CONTENTS "${${CPLINE_PARTS}}")

      generate_compound_pipeline_lists(
        COMPOUND_PIPELINE ${CPLINE}
        PIPELINES ${CPLINE_PARTS_CONTENTS}
        OUTPUT_DIR ${PIPELINE_FILES_DIR})

      include(${CPLINE})
    endforeach()

    generate_pipeline_runner_lists(
      PIPELINES ${LLVMIR_PIPELINES_COMPOUND}
      DEPENDS ${LPS_DEPENDS}
      OUTPUT_FILE ${LPS_OUTPUT_FILE}
      OUTPUT_DIR ${PIPELINE_FILES_DIR})
  endif()
endfunction()
