FROM ubuntu:14.04
MAINTAINER ian@blenke.com 

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository 'deb http://debian.opennms.org stable main' && \
    wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add - && \
    apt-get update && \
    debconf-set-selections <<< "postfix postfix/mailname string localhost" \
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'" \
    apt-get install -y build-essential checkinstall postgresql-client postgresql \
      git-core libpq-dev openjdk-7-jre postfix opennms \
    /usr/share/opennms/bin/runjava -S /usr/bin/java \
    rm -rf /var/lib/apt/lists/*

ADD scripts/ /scripts
RUN chmod 755 /scripts/init

VOLUME /var/lib/postgresql

EXPOSE 8980

CMD ["/scripts/init"]

