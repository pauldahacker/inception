FROM alpine:3.21

RUN apk update && apk add --no-cache mariadb mariadb-client

# Create necessary directories and config
RUN mkdir /var/run/mysqld && \
    chmod 777 /var/run/mysqld && \
    { echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address=0.0.0.0'; \
    } | tee /etc/my.cnf.d/docker.cnf && \
    sed -i "s|skip-networking|skip-networking=0|g" /etc/my.cnf.d/mariadb-server.cnf

# Initialize DB structure
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Copy and configure entrypoint
COPY requirements/mariadb/conf/create_db.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch to non-root user
USER mysql

# Use entrypoint and pass CMD as arguments to it
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/mysqld", "--skip-log-error"]

EXPOSE 3306
