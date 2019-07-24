#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Debug is disabled by default.
DEBUG=false
DEBUG_OPT=

# Default paramentes.
NEXUS_SCRIPT=/opt/nexus-script
HOST=http://localhost:8081
USERNAME=admin
PASSWORD=`cat ${NEXUS_DATA}/admin.password`

# For each argument.
while :; do
	case ${1} in
		
		# If debuf is enabled.
		--debug)
			DEBUG=true
			DEBUG_OPT="--debug"
			;;

		# User name.
		-u|username)
			USERNAME=${2}
			shift
			;;

		# User password.
		-u|password)
			PASSWORD=${2}
			shift
			;;

		# Script.
		-n|script-name)
			SCRIPT_NAME=${2}
			shift
			;;

		# Script.
		-f|script-file)
			SCRIPT_FILE=${2}
			shift
			;;

		# Other option.
		?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;

		# No more options.
		*)
			break

	esac 
	shift
done

# Using unavaialble variables should fail the script.
set -o nounset

# Enables interruption signal handling.
trap - INT TERM

# Print arguments if on debug mode.
${DEBUG} && echo "Running 'nexus_run_script'"
${DEBUG} && echo "USERNAME=${USERNAME}"
${DEBUG} && echo "PASSWORD=${PASSWORD}"
${DEBUG} && echo "SCRIPT_NAME=${SCRIPT_NAME}"
${DEBUG} && echo "SCRIPT_FILE=${SCRIPT_FILE}"

# Creates the script.
groovy -Dgroovy.grape.report.downloads=true -Dgrape.config=${NEXUS_SCRIPT}/nexusGrapeConfig.xml ${NEXUS_SCRIPT}/groovy/nexusAddUpdateScript.groovy -u "${USERNAME}" -p "${PASSWORD}" -n "${SCRIPT_NAME}" -f "${SCRIPT_FILE}" -h "${HOST}"
${DEBUG} && printf "\nPublished ${SCRIPT_FILE} as ${SCRIPT_NAME}\n\n"

# Runs the script.
curl -v -X POST -u ${USERNAME}:${PASSWORD} --header "Content-Type: text/plain" "${HOST}/service/rest/v1/script/${SCRIPT_NAME}/run"
${DEBUG} && printf "\nSuccessfully executed ${SCRIPT_NAME} script\n\n\n"

