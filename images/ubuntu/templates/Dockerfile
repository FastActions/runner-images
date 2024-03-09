# Use the specified base image
FROM blacksmithcihello/rootfs-packer:040324-1

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set the MySQL root password
ENV MYSQL_ROOT_PASSWORD=root

# Mysql setting up root password
RUN echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections

# Install MySQL Client
RUN apt-get update && \
    apt-get install -y mysql-client

# Install MySQL Server without starting the service
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

# Install MySQL Dev tools
RUN apt-get install -y libmysqlclient-dev

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove the policy-rc.d script
RUN rm -f /usr/sbin/policy-rc.d

# Expose the MySQL port
EXPOSE 3306

# Start MySQL Server
CMD ["mysqld_safe"]
