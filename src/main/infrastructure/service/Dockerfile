# From Nexus image.
FROM sonatype/nexus3:3.16.0

# Sets the current user to root.
USER root

# Sets localtime timezone.
RUN mv /etc/localtime /etc/localtime.bak && \
	ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
ENV TZ=America/Sao_Paulo

# Installs groovy.
RUN yum update -y && \
	yum install -y groovy && \
	rm -rf /var/cache/yum

# Copies the scripts.
RUN mkdir -p /opt/nexus-script
COPY script /opt/nexus-script
RUN chown -R nexus:nexus /opt/nexus-script && \
	ln -s /opt/nexus-script/*.sh /usr/bin && \
	for f in /usr/bin/nexus*.sh; \
	do \
		chown nexus:nexus $f && \	
		mv -- "$f" "${f%.sh}"; \
	done
	
# Sets the user back to nexus.
USER nexus

# Sets configuration.
ENV INSTALL4J_ADD_VM_PARAMS="-Xms128m -Xmx2g -XX:MaxDirectMemorySize=3g -Xincgc"
ENV NEXUS_DATA=persistent-data

# Entrypoint.
ENTRYPOINT [ "nexus_init" ]
CMD []
