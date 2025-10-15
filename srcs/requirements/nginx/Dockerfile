# Use Debian Bookworm as the base image
FROM debian:bookworm

# Update packages and install Nginx web server along with development tools
RUN apt update && apt upgrade -y && apt install -y nginx
RUN apt install vim -y
RUN apt install curl -y 
# Create SSL directory and install OpenSSL for certificate generation
RUN mkdir -p /etc/nginx/ssl
RUN apt install openssl -y

# Generate self-signed SSL certificate for HTTPS
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=/UID=login"

# Create Nginx runtime directory
RUN mkdir -p /var/run/nginx

# Set permissions for web directory (though this might be redundant since we use /var/www/wordpress)
RUN chmod -R 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Create Nginx configuration file with HTTPS server block that handles WordPress
# Includes SSL/TLS settings, server root, file extensions, and PHP processing
RUN echo "events {}" > /etc/nginx/nginx.conf && \
    echo "" >> /etc/nginx/nginx.conf && \
    echo "http {" >> /etc/nginx/nginx.conf && \
    echo "    server {" >> /etc/nginx/nginx.conf && \
    echo "        #SSL/TLS Configuration" >> /etc/nginx/nginx.conf && \
    echo "        listen 443 ssl;" >> /etc/nginx/nginx.conf && \
    echo "        ssl_protocols TLSv1.2 TLSv1.3;" >> /etc/nginx/nginx.conf && \
    echo "        ssl_certificate /etc/nginx/ssl/inception.crt;" >> /etc/nginx/nginx.conf && \
    echo "        ssl_certificate_key /etc/nginx/ssl/inception.key;" >> /etc/nginx/nginx.conf && \
    echo "" >> /etc/nginx/nginx.conf && \
    echo "        #root and index and server_name" >> /etc/nginx/nginx.conf && \
    echo "        root /var/www/wordpress;" >> /etc/nginx/nginx.conf && \
    echo "        server_name jowander.42.fr;" >> /etc/nginx/nginx.conf && \
    echo "        index index.php index.html index.htm;" >> /etc/nginx/nginx.conf && \
    echo "" >> /etc/nginx/nginx.conf && \
    echo "        #location" >> /etc/nginx/nginx.conf && \
    echo "        location / {" >> /etc/nginx/nginx.conf && \
    echo "            try_files \$uri \$uri/ /index.php\$is_args\$args;" >> /etc/nginx/nginx.conf && \
    echo "        }" >> /etc/nginx/nginx.conf && \
    echo "" >> /etc/nginx/nginx.conf && \
    echo "        location ~ \\.php\$ {" >> /etc/nginx/nginx.conf && \
    echo "            fastcgi_split_path_info ^(.+\\.php)(/.+)\$;" >> /etc/nginx/nginx.conf && \
    echo "            fastcgi_pass wordpress:9000;" >> /etc/nginx/nginx.conf && \
    echo "            fastcgi_index index.php;" >> /etc/nginx/nginx.conf && \
    echo "            include fastcgi.conf;" >> /etc/nginx/nginx.conf && \
    echo "        }   " >> /etc/nginx/nginx.conf && \
    echo "" >> /etc/nginx/nginx.conf && \
    echo "        include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf && \
    echo "    }" >> /etc/nginx/nginx.conf && \
    echo "}" >> /etc/nginx/nginx.conf

# Start Nginx in foreground mode when container starts
CMD ["nginx", "-g", "daemon off;"]