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

# --help was passed in, display the jmeter help
if [[ "${OPTIONS}" == *"--help"* ]]; then
    jmeter --help && exit 0
fi

# Set output directory
OUTPUT_DIR="${JMETER_HOME}/output"

# Set some default options
DEFAULT_OPTIONS="-n -j ${OUTPUT_DIR}/jmeter.log"

# Look for default project file if one wasn't provided
PROJECT_FILE="/project.jmx"
if [[ "${OPTIONS}" != *"-t "* ]]; then
    # See if they provided a default file via volume mount, if not, exit with the default help message
    if [[ ! -f ${PROJECT_FILE} ]] && [[ -z "${OPTIONS}" ]]; then
        jmeter --help && exit 0
    fi
    if [[ ! -f ${PROJECT_FILE} ]]; then
        echo -e "A project file could not be found.\nPlease be sure to mount your project file to ${PROJECT_FILE},\nor mount to an alternate location and include the -t [filepath] option"
        exit 1
    fi
    DEFAULT_OPTIONS="${DEFAULT_OPTIONS} -t ${PROJECT_FILE}"
fi

# Check for dashboard
DASHBOARD="${DASHBOARD:-0}"
if [[ "${DASHBOARD}" = "1" ]]; then
    DEFAULT_OPTIONS="${DEFAULT_OPTIONS} -e -f -o ${OUTPUT_DIR}/dashboard -l ${OUTPUT_DIR}/log.jtl"
fi

# See if we should fail on error
if [[ "${FAIL_ON_ERROR:-0}" != "1" ]]; then
    jmeter ${DEFAULT_OPTIONS} ${OPTIONS} || exit 1
    exit 0
fi

exec 5>&1
RESULTS=$(jmeter ${DEFAULT_OPTIONS} ${OPTIONS} | tee >(cat - >&5))
(echo ${RESULTS} | grep -Eq 'summary =.*Err:.*0 \(0\.00\%\)') && exit 0 || exit 1
