#!/bin/bash
set -e

# If "jmeter" was passed as the first arg, remove it
for arg do
    shift
    [[ "$arg" = "jmeter" ]] && continue
    set -- "$@" "$arg"
done

# Get options the user passed in
OPTIONS="${@}"

# If nothing was passed in, or --help was passed in, display the jmeter help
if [[ -z "${OPTIONS}" ]] || [[ "${OPTIONS}" == *"--help"* ]]; then
    jmeter --help && exit 0
fi

# Set output directory
OUTPUT_DIR="${JMETER_HOME}/output"

# Set some default options
DEFAULT_OPTIONS="-n -j ${OUTPUT_DIR}/jmeter.log"

# Look for default project file if one wasn't provided
PROJECT_FILE="/project.jmx"
if [[ "${OPTIONS}" != *"-t "* ]]; then
    DEFAULT_OPTIONS="${DEFAULT_OPTIONS} -t ${PROJECT_FILE}"
fi

# Check for dashboard
DASHBOARD="${DASHBOARD:-0}"
if [[ "${DASHBOARD}" = "1" ]]; then
    DEFAULT_OPTIONS="${DEFAULT_OPTIONS} -e -f -o ${OUTPUT_DIR}/dashboard -l ${OUTPUT_DIR}/log.jtl"
fi

jmeter ${DEFAULT_OPTIONS} ${OPTIONS}

