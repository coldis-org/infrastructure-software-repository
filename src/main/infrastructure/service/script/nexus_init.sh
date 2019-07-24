#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Default parameters.
DEBUG=false
DEBUG_OPT=
FORCE_CONFIGURATION=false
FORCE_CONFIGURATION_OPT=
START_POOLING_INTERVAL=15
START_POOLING_RETRIES=20
NEXUS_SCRIPT=/opt/nexus-script

# For each argument.
while :; do
	case ${1} in
		
		# If debuf is enabled.
		--debug)
			DEBUG=true
			DEBUG_OPT="--debug"
			;;

		# Force the repository to be configured.
		-c|--force-configuration)
			FORCE_CONFIGURATION=true
			FORCE_CONFIGURATION_OPT=--force-configuration
			;;

		# Start pooling interval.
		-p|--start-pooling-interval)
			START_POOLING_INTERVAL=${2}
			shift
			;;

		# Start pooling interval.
		-r|--start-pooling-retries)
			START_POOLING_RETRIES=${2}
			shift
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
${DEBUG} && echo  "Running 'nexus_init'"
${DEBUG} && echo "FORCE_CONFIGURATION=${FORCE_CONFIGURATION}"
${DEBUG} && echo "START_POOLING_INTERVAL=${START_POOLING_INTERVAL}"
${DEBUG} && echo "START_POOLING_RETRIES=${START_POOLING_RETRIES}"

# Starts job control.
set -m

# Runs the config in the backgrond.
nexus_configure ${DEBUG_OPT} ${FORCE_CONFIGURATION_OPT} \
	--start-pooling-interval ${START_POOLING_INTERVAL} \
	--start-pooling-retries ${START_POOLING_RETRIES} \
	&

# Executes the main process.
${DEBUG} && echo "${SONATYPE_DIR}/start-nexus-repository-manager.sh"
exec ${SONATYPE_DIR}/start-nexus-repository-manager.sh

