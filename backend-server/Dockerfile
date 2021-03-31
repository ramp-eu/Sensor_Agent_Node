FROM esthesis/esthesis-platform-backend-server

COPY ./config /app/config
COPY ./entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/config/autoconfigure_esthesis.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]