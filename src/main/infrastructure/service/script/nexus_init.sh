#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Debug is disabled by default.
if ${DEBUG}
then
	DEBUG=true
	DEBUG_OPT=--debug
else 
	DEBUG=false
	DEBUG_OPT=
fi

# Default parameters.
NEXUS_SCRIPT=/opt/nexus-script
STARTUP_WAIT=180

# For each argument.
while :; do
	case ${1} in
		
		# If debuf is enabled.
		--debug)
			DEBUG=true
			DEBUG_OPT="--debug"
			;;

		# Startup wait.
		-w|startup-wait)
			STARTUP_WAIT=${2}
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
${DEBUG} && echo  "Running 'nexus_init'"

# Starts job control.
set -m

# Executes the init script in the background.
${DEBUG} && echo "Nexus data at ${NEXUS_DATA}"
${DEBUG} && echo "${SONATYPE_DIR}/start-nexus-repository-manager.sh &"
exec ${SONATYPE_DIR}/start-nexus-repository-manager.sh &

# If the container has not been configured yet.
if ! [ -f ${NEXUS_DATA}/configured.lock ]
then
	${DEBUG} && echo "Container not configured yet. Configuring..."
	# Startup wait.
	sleep ${STARTUP_WAIT}
	# Configures the repositories.
	nexus_run_script ${DEBUG_OPT} -n nexusConfigureRepositories -f ${NEXUS_SCRIPT}/groovy/nexusConfigureRepositories.groovy
	${DEBUG} && echo "Repositories configured"
	# Sets that the container has been configured.
	touch ${NEXUS_DATA}/configured.lock
fi

# Gets the nexus service back to foreground.
${DEBUG} && echo "Joining back the main process"
fg

