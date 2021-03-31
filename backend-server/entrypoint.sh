#!/bin/sh
touch /app/logs.txt
nohup /bin/java -jar -Dspring.profiles.active=prod /app/esthesis-platform-backend-server.jar >>/app/logs.txt 2>&1 &
echo $! >/app/server.pid

/app/config/autoconfigure_esthesis.sh
kill $(cat /app/server.pid)

/bin/java -jar -Dspring.profiles.active=prod /app/esthesis-platform-backend-server.jar
