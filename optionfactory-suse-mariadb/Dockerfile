FROM opensuse:13.2
MAINTAINER Roberto Ferranti



RUN groupadd -r mysql && useradd -r -g mysql mysql


COPY install-ps1.sh /etc/bash.bashrc
RUN zypper -n -q install tar curl mariadb && zypper -n -q clean --all

COPY install-spawn-and-tail.sh /tmp/install-spawn-and-tail.sh
RUN /tmp/install-spawn-and-tail.sh && rm /tmp/install-spawn-and-tail.sh


RUN rm -rf /var/lib/mysql && mkdir /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql
RUN mkdir -p /var/run/mysql && chown -R mysql:mysql /var/run/mysql
RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql
COPY my.cnf /etc/my.cnf
RUN chown -R mysql:mysql /etc/my.cnf
COPY mysql-first-time.sql /sql-init/mysql-first-time.sql
COPY mysql /mysql

USER mysql
EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init/"]
ENTRYPOINT ["/mysql"]