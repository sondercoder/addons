#!/usr/bin/env bashio
set -e

# Read from STDIN aliases to send shutdown
while read -r input; do
    # parse JSON value
    input=$(bashio::jq "${input}" '.')
    bashio::log.info "Read alias: $input"

    # Find aliases -> computer
    for computer in $(bashio::config 'computers|keys'); do
        ALIAS=$(bashio::config "computers[${computer}].alias")
        ADDRESS=$(bashio::config "computers[${computer}].address")
        CREDENTIALS=$(bashio::config "computers[${computer}].credentials")
        DELAY=$(bashio::config "computers[${computer}].delay")
        MESSAGE=$(bashio::config "computers[${computer}].message")
        ABORT=$(bashio::config "computers[${computer}].abort")
  
        # Not the correct alias
        if ! bashio::var.equals "$ALIAS" "$input"; then
            continue
        fi

        # Check if delay is not empty
        if bashio::var.equals "$DELAY" "null"; then
            DELAY="0"
        fi
        # Check if Abort = true
        if bashio::var.equals "$ABORT" "true"; then
            bashio::log.info "Abort $input -> $ADDRESS"
            if ! msg="$(net rpc abortshutdown -I "$ADDRESS" -U "$CREDENTIALS")"; then
                bashio::log.error "Shutdown fails -> $msg"
        else
        bashio::log.info "Shutdown $input -> $ADDRESS"
        if ! msg="$(net rpc shutdown -I "$ADDRESS" -U "$CREDENTIALS" -t "$DELAY" -C "$MESSAGE")"; then
            bashio::log.error "Shutdown fails -> $msg"
        fi
    done
done
