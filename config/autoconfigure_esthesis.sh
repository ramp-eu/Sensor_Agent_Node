#!/usr/bin/env sh

. ./esthesis.conf
readonly DATETIME="$(date +'%Y-%m-%dT%H:%M:%S%z')"

################################################################################
# Generic Functions
################################################################################

##################################################
# Display error messages
# Arguments:
#  Custom error message
##################################################
err() {
   echo '['"${DATETIME}"']: PID '$$' : ERROR:  '$* >&2
   exit 1
}

##################################################
# Display info messages 
# Arguments:
#  Custom info message
##################################################
info(){
  echo '['"${DATETIME}"']: PID '$$' : INFO:  '$*
}

##################################################
# Display warn messages 
# Arguments:
#  Custom warn message
##################################################
warn(){
  echo '['"${DATETIME}"']: PID '$$' : WARN:  '$*
}

################################################################################
# Script specific Functions
################################################################################
timeout=10
start_time=$(date +%s)
end_time=`expr $start_time + $timeout`
esthesis_online=0
FQDN="$(echo ${BASE_URL} | sed -n "s|.*://\(.*\)|\1|p")"
EMAIL="admin@esthes.is"
PASSWORD="admin"

info "Executing Esthesis autoconfiguration script"

AUTH_END_POINT="/api/users/auth"
until [ $esthesis_online -eq 1 ] || [ $(date +%s) -gt $end_time ]; do
    info "Starting connection with Esthesis server..."
    RESPONCE="$(curl --silent --location \
    --connect-timeout 10 \
    --request POST "${BASE_URL}${AUTH_END_POINT}" \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "email": "'${EMAIL}'",
        "password": "'${PASSWORD}'"
    }')"
    if [ -z "${RESPONCE}" ]; then
        warn "Esthesis server not responding"; 
        info "Retrying connection" 
    elif echo "${RESPONCE}"|grep -q 404 ; then
        err "HTTP status 404"
    elif echo "${RESPONCE}"|grep -q '"error":"Forbidden"' || \
            echo "${RESPONCE}"|grep -q "There was a problem with this request"; then 
        err "Access forbidden. Wrong username, password or api path"
    else
        esthesis_online=1
    fi
    sleep 1
done
if [ $esthesis_online -eq 0 ]; then 
    err "Esthesis autoconfiguration failed"
fi
readonly TOKEN="$(echo "${RESPONCE}" | sed -n 's|.*"jwt":"\([^"]*\)".*|\1|p' )"
if [ -z TOKEN ]; then
    err "Bad esthesis auth Bearer Token"
fi

# Set certificate authority
CA_END_POINT="/api/cas"
RESPONCE="$(curl --silent --location \
--connect-timeout 10 \
--request POST "${BASE_URL}${CA_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '{"cn":"'${CA}'","validity":"'${CA_EXPIRE_DATE}'"}')"
if [ -z "${RESPONCE}" ]; then
    err "Could not add Certificate Authority"
elif ! echo ${RESPONCE}|grep -q "${CA}"; then
    err "There was a problem on create CA request"
fi

# Set certificate
CERT_END_POINT="/api/certificates"
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${CERT_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '{"cn":"'${CERT}'","validity":"'${CERT_EXPIRE_DATE}'","issuer":"'${CA}'"}')"
if [ -z "${RESPONCE}" ]; then
    err "Could not add Certificate"
elif ! echo ${RESPONCE}|grep -q "${CA}"; then
    err "There was a problem on create certificate request"
fi

SETTINGS_END_POINT="/api/settings/byNames"
# Set platform certificate
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${SETTINGS_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '[{"key":"deviceOutgoingEncryption","value":"NOT_ENCRYPTED"},{"key":"deviceIncomingEncryption","value":"NOT_ENCRYPTED"},{"key":"deviceOutgoingSignature","value":"NOT_SIGNED"},{"key":"deviceIncomingSignature","value":"NOT_SIGNED"},{"key":"platformCertificate","value":1}]')"

# Set device registration parameters
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${SETTINGS_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '[{"key":"deviceRegistration","value":"OPEN"},{"key":"deviceTagsAlgorithm","value":"ALL"},{"key":"deviceRootCA","value":13}]')"

# Set device provisioning url
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${SETTINGS_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '[{"key":"provisioningUrl","value":"'${BASE_URL}'"},{"key":"provisioningEncrypt","value":"NOT_ENCRYPTED"},{"key":"provisioningSign","value":"NOT_SIGNED"}]')"

# Register Nifi
INFRA_NIFI_END_POINT="/api/infrastructure/nifi"
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${INFRA_NIFI_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '{
    "name": "NiFi",
    "url": "http://esthesis-nifi:9080",
    "state": true,
    "dtUrl": "http://esthesis-nifi:20000"
}')"

# Sunc Nifi
SYNC_NIFI_END_POINT="/api/sync"
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${SYNC_NIFI_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: text/plain' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '')"

# Create device tag
TAG_END_POINT="/api/tags"
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${TAG_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '{"name":"'${DEFAULT_TAG}'"}')"

# Register MQTT
MQTT_END_POINT="/api/mqtt-server"
RESPONCE="$(curl --silent --location \
--request POST "${BASE_URL}${MQTT_END_POINT}" \
--header 'Accept: application/json, text/plain, */*' \
--header 'Authorization: Bearer '${TOKEN} \
--header 'Content-Type: application/json' \
--header 'Sec-Fetch-Site: same-origin' \
--header 'Sec-Fetch-Mode: cors' \
--header 'Sec-Fetch-Dest: empty' \
--data-raw '{"name":"MQTT","ipAddress":"tcp://'${FQDN}':1883","state":true,"tags":[1]}')"
