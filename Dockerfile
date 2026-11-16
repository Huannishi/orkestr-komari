FROM python:3-alpine

RUN apk add --no-cache curl

WORKDIR /app
COPY start.sh /app/start.sh
COPY index.html /app/index.html
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
