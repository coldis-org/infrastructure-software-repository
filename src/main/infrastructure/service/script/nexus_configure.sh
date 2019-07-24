#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Default parameters.
DEBUG=false
DEBUG_OPT=
FORCE_CONFIGURATION=false
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
${DEBUG} && echo  "Running 'nexus_configure'"
${DEBUG} && echo "FORCE_CONFIGURATION=${FORCE_CONFIGURATION}"
${DEBUG} && echo "START_POOLING_RETRIES=${START_POOLING_RETRIES}"

# If the container has not been configured yet.
if ${FORCE_CONFIGURATION} || [ ! -f ${NEXUS_DATA}/configured.lock ]
then

	# While the service is not up.
	RETRY_NUMBER=0
	while [ ${RETRY_NUMBER} -lt ${START_POOLING_RETRIES} ]
	do
		
		# If the service has started.
		if [ "$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8081)" = "200" ]
		then
	
			# Waits a bit more.	
			sleep ${START_POOLING_INTERVAL}
			sleep ${START_POOLING_INTERVAL}
			
			# Configures the repositories.
			${DEBUG} && echo "Repository not configured yet. Configuring..."
			REPO_CONFIGURED=`nexus_run_script ${DEBUG_OPT} \
				-n nexusConfigureRepositories \
				-f ${NEXUS_SCRIPT}/groovy/nexusConfigureRepositories.groovy || \
			echo "false"`
			
			# If the repository has not been configured
			if [ "${REPO_CONFIGURED}" = "false" ]
			then
				echo "Failed to configure repositories."
			# If the repository has been configured
			else
				# Sets that the container has been configured.
				echo "Repositories configured"
				touch ${NEXUS_DATA}/configured.lock
			fi
			break
	
		# If the service has not started.
		else 
			
			${DEBUG} && echo "Service not ready. Waiting another ${START_POOLING_INTERVAL} seconds."
			# Waits a bit.
			sleep ${START_POOLING_INTERVAL}
			
		fi
	
		# Increment the retry number.
		RETRY_NUMBER=$((${RETRY_NUMBER} + 1))
	done
	
	# If the service does not start, 
	if [ ${RETRY_NUMBER} -ge ${START_POOLING_RETRIES} ]
	then
		exit "Process did not start within expected interval"
	fi
	
fi
