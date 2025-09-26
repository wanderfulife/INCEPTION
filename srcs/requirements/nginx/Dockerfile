# Use the penultimate stable version of Debian as the base image.
FROM debian:bullseye

# Update package list and install NGINX and OpenSSL.
# openssl is needed to create the self-signed SSL certificate.
RUN apt-get update && apt-get install -y nginx openssl

# --- Generate Self-Signed SSL Certificate ---
# This command creates a certificate and a private key for enabling HTTPS.
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    # -x509: Creates a self-signed certificate.
    # -nodes: Creates a key without a passphrase.
    # -days 365: Sets the certificate's validity to one year.
    # -newkey rsa:2048: Creates a new 2048-bit RSA private key.
    
    # Specifies the output file for the private key.
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    # Specifies the output file for the certificate.
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    # Provides the certificate subject information non-interactively.
    # CN (Common Name) is the most important field and must match the domain name.
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=jowander/CN=jowander.42.fr"

# Copy the custom NGINX server block configuration.
# This will overwrite the default NGINX site configuration.
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Expose port 443 for HTTPS traffic.
EXPOSE 443

# Set the command to run when the container starts.
# `nginx -g 'daemon off;'` starts NGINX in the foreground, which is the standard
# practice for containers. This makes NGINX the main process (PID 1).
CMD ["nginx", "-g", "daemon off;"]
