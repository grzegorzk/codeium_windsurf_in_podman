#!/usr/bin/env bash

set -e

chmod 0500 ~/.ssh
chmod 0400 ~/.ssh/*
touch ~/.ssh/config
chmod 0700 ~/.ssh/config

# NOTE: setting up gnome keyring, https://unix.stackexchange.com/questions/473528/how-do-you-enable-the-secret-tool-command-backed-by-gnome-keyring-libsecret-an#answer-548005
eval "$(dbus-launch --sh-syntax)"
mkdir -p ~/.cache
mkdir -p ~/.local/share/keyrings
eval "$(printf '\n' | gnome-keyring-daemon --unlock)"
eval "$(printf '\n' | /usr/bin/gnome-keyring-daemon --start)"

/usr/sbin/windsurf
windsurf_pid=$(ps -ef | grep windsurf | tr -s ' ' | cut -d ' ' -f2 | head -n 1)

_term() {
    echo "Termination initiated (probably by ctrl+c)"
    if [ -n "$windsurf_pid" ]; then
        kill -INT "$windsurf_pid"
        for icnt in $(seq 1 120); do
            if [ -z "$(ps -q "$windsurf_pid" -o comm=)" ]; then
                break;
            fi;
            echo "Waiting for Windsurf to terminate...";
            sleep 1;
        done

        if [ -n "$(ps -q "$windsurf_pid" -o comm=)" ]; then
            kill -9 "$windsurf_pid"
            exit 1
        fi;
    fi;
    echo "Windsurf terminated"
    exit 0
}

# 0 - EXIT
# 1 - HUP
# 2 - INT
# 3 - QUIT
# 13 - PIPE
# 15 - TERM
trap _term 1 2 3 13 15

tail --pid=$windsurf_pid -f /dev/null
