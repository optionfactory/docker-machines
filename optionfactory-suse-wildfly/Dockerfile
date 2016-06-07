FROM archiva/suse-jdk:latest
MAINTAINER Roberto Ferranti

RUN groupadd -r wildfly && useradd -r -g wildfly wildfly
COPY install-wildfly.sh /tmp/install-wildfly.sh
RUN /tmp/install-wildfly.sh && rm /tmp/install-wildfly.sh

COPY configuration/* /opt/wildfly/standalone/configuration/
RUN chown -R wildfly:wildfly /opt/wildfly

COPY wildfly /wildfly

USER wildfly

EXPOSE 8443 9990

ENTRYPOINT ["/wildfly"]