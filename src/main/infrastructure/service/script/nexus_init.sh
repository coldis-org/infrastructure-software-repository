#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Debug is disabled by default.
DEBUG=false
DEBUG_OPT=

# Default parameters.
STARTUP_WAIT=90

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
${DEBUG} && echo "${SONATYPE_DIR}/start-nexus-repository-manager.sh &"
exec ${SONATYPE_DIR}/start-nexus-repository-manager.sh &

# If the container has not been configured yet.
if ! [ -f ${NEXUS_DATA}/configured.lock ]
then
	${DEBUG} && echo "Container not configured yet. Configuring..."
	# Startup wait.
	sleep ${STARTUP_WAIT}
	# Configures the repositories.
	nexus_run_script -n repositories -f /opt/nexus-script/repositories.groovy ${DEBUG_OPT}
	# Sets that the container has been configured.
	touch ${NEXUS_DATA}/configured.lock
fi

# Gets the nexus service back to foreground.
${DEBUG} && echo "Joining back the main process"
fg

