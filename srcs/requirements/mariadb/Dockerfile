FROM alpine:3.19

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

RUN mkdir -p /etc/my.cnf.d && echo '[mysqld]\nskip-host-cache\nskip-name-resolve\nbind-address=0.0.0.0' > /etc/my.cnf.d/docker.cnf

RUN sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf

EXPOSE 3306

COPY conf/db.sh /usr/local/bin/db.sh
RUN chmod +x /usr/local/bin/db.sh

CMD ["/usr/local/bin/db.sh"]
