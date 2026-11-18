#!/usr/bin/env bash
MODE="${1:-dark}"

# If mode was not passed as argument, query noctalia or detect from gsettings
if [[ -z "$1" ]]; then
    MODE=$(noctalia msg theme-mode-get 2>/dev/null | tr -d '[:space:]')
fi

CONFIG_FILE="$HOME/.config/foot/foot.ini"

if [[ "$MODE" == "light" ]]; then
    # Signal all running foot instances to switch to light palette
    pkill -SIGUSR2 foot 2>/dev/null || true
    # Set default theme in foot.ini for newly opened windows
    if [[ -f "$CONFIG_FILE" ]]; then
        if grep -q '^initial-color-theme=' "$CONFIG_FILE"; then
            sed -i 's/^initial-color-theme=.*/initial-color-theme=light/' "$CONFIG_FILE"
        elif grep -q '^\[main\]' "$CONFIG_FILE"; then
            sed -i '/^\[main\]/a initial-color-theme=light' "$CONFIG_FILE"
        fi
    fi
else
    # Signal all running foot instances to switch to dark palette
    pkill -SIGUSR1 foot 2>/dev/null || true
    # Set default theme in foot.ini for newly opened windows
    if [[ -f "$CONFIG_FILE" ]]; then
        if grep -q '^initial-color-theme=' "$CONFIG_FILE"; then
            sed -i 's/^initial-color-theme=.*/initial-color-theme=dark/' "$CONFIG_FILE"
        elif grep -q '^\[main\]' "$CONFIG_FILE"; then
            sed -i '/^\[main\]/a initial-color-theme=dark' "$CONFIG_FILE"
        fi
    fi
fi
