FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/sites-available/default

COPY ssl/ppeckham.42.fr.crt /etc/nginx/ssl/ppeckham.42.fr.crt

COPY ssl/ppeckham.42.fr.key /etc/nginx/ssl/ppeckham.42.fr.key

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
