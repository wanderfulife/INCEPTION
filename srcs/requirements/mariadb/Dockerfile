FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

COPY tools/configure-db.sh /usr/local/bin/configure-db.sh
RUN chmod +x /usr/local/bin/configure-db.sh

EXPOSE 3306

CMD ["/usr/local/bin/configure-db.sh"]
