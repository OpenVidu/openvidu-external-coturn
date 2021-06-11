#!/bin/sh -x

# Trap exit signal
exit_func() {
    exit 1
}
trap exit_func TERM INT

export CRONTIME="${CRONTIME:-12h}"
export COTURN_CONTAINER_NAME="${COTURN_CONTAINER_NAME:-coturn}"

while :; do
    certbot "$@";
    chmod 777 -R /etc/letsencrypt;
    # Send SIGUSR2 signal to coturn
    docker kill --signal=SIGUSR2 "${COTURN_CONTAINER_NAME}"
    # Sleep CRONTIME seconds for next check
    sleep "${CRONTIME}" &
    # Wait for sleep without blocking signals
    wait $!
done;
