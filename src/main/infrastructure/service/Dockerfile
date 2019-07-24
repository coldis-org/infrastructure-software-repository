# From Nexus image.
FROM sonatype/nexus3:3.17.0

# Sets the current user to root.
USER root

# Sets localtime timezone.
RUN mv /etc/localtime /etc/localtime.bak && \
	ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
ENV TZ=America/Sao_Paulo

# Installs groovy.
RUN yum update -y && \
	yum install -y groovy curl && \
	rm -rf /var/cache/yum

# Copies scripts.
ENV NEXUS_SCRIPT=/opt/nexus-script
RUN mkdir -p ${NEXUS_SCRIPT}
COPY script ${NEXUS_SCRIPT}
RUN chown -R nexus:nexus ${NEXUS_SCRIPT} && \
	ln -s ${NEXUS_SCRIPT}/*.sh /usr/bin && \
	for FILE in /usr/bin/nexus*.sh; \
	do \
		chown nexus:nexus ${FILE} && \	
		mv -- "${FILE}" "${FILE%.sh}"; \
	done
	
# Sets the user back to nexus.
USER nexus

# Sets configuration.
ENV INSTALL4J_ADD_VM_PARAMS="-Xms128m -Xmx4g -XX:MaxDirectMemorySize=4g -Xincgc"

# Entrypoint.
ENTRYPOINT [ "nexus_init" ]
CMD []
