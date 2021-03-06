# cmake file

include(CMakeParseArguments)

set(_THIS_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(_GEN_SCRIPTS_DIR "${_THIS_LIST_DIR}/../../scripts/")

function(generate_compound_pipeline_lists)
  set(options)
  set(oneValueArgs COMPOUND_PIPELINE OUTPUT_DIR)
  set(multiValueArgs PIPELINES)
  cmake_parse_arguments(GENPLISTS
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT GENPLISTS_COMPOUND_PIPELINE)
    message(FATAL_ERROR "${_MOD_NAME} generator command is missing \
    COMPOUND_PIPELINE option")
  endif()

  if(NOT GENPLISTS_OUTPUT_DIR)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    OUTPUT_DIR option")
  endif()

  if(NOT GENPLISTS_PIPELINES)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    PIPELINES option")
  endif()

  set(OUTFILE "${GENPLISTS_COMPOUND_PIPELINE}.cmake")

  execute_process(
    COMMAND ${_GEN_SCRIPTS_DIR}/compound_pipeline_generator.py
    -t ${_GEN_SCRIPTS_DIR}/templates/
    -c ${GENPLISTS_COMPOUND_PIPELINE}
    -p "${GENPLISTS_PIPELINES}"
    -f ${OUTFILE}
    WORKING_DIRECTORY ${GENPLISTS_OUTPUT_DIR}
    ERROR_VARIABLE ERR_MSG
    OUTPUT_VARIABLE ERR_MSG
    RESULT_VARIABLE RC)

  if(RC)
    message(SEND_ERROR "${_MOD_NAME}: ${RC}")
    message(SEND_ERROR "${ERR_MSG}")
    message(FATAL_ERROR "${_MOD_NAME}: Failed to generate compound pipelines \
    lists file")
  endif()

  message(STATUS "${_MOD_NAME}: Generated compound pipelines lists file: \
  ${OUTFILE}")
endfunction()

function(generate_pipeline_runner_lists)
  set(options)
  set(oneValueArgs DEPENDS OUTPUT_FILE OUTPUT_DIR)
  set(multiValueArgs PIPELINES)
  cmake_parse_arguments(GENPLISTS
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT GENPLISTS_DEPENDS)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    DEPENDS option")
  endif()

  if(NOT GENPLISTS_OUTPUT_FILE)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    OUTPUT_FILE option")
  endif()

  if(NOT GENPLISTS_OUTPUT_DIR)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    OUTPUT_DIR option")
  endif()

  if(NOT GENPLISTS_PIPELINES)
    message(FATAL_ERROR "${_MOD_NAME}: generator command is missing \
    PIPELINES option")
  endif()

  set(OUTFILE "${GENPLISTS_OUTPUT_FILE}.cmake")

  execute_process(
    COMMAND ${_GEN_SCRIPTS_DIR}/pipeline_runner_generator.py
    -t ${_GEN_SCRIPTS_DIR}/templates/
    -p "${GENPLISTS_PIPELINES}"
    -d ${GENPLISTS_DEPENDS}
    -f ${OUTFILE}
    WORKING_DIRECTORY ${GENPLISTS_OUTPUT_DIR}
    ERROR_VARIABLE ERR_MSG
    OUTPUT_VARIABLE ERR_MSG
    RESULT_VARIABLE RC)

  if(RC)
    message(SEND_ERROR "${_MOD_NAME}: ${RC}")
    message(SEND_ERROR "${ERR_MSG}")
    message(FATAL_ERROR "${_MOD_NAME}: Failed to generate pipelines runner \
    lists file")
  endif()

  message(STATUS "${_MOD_NAME}: Generated pipelines runner lists file: \
  ${OUTFILE}")
endfunction()

