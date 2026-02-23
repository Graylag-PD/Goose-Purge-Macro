#!/bin/bash

echo "Goose Purge Macro installation script - installing"
echo "------------------------------------------------------------"

# ------------------------------------------------------------
# Helper: usage
# ------------------------------------------------------------
usage() {
    echo "Usage: $0 [-c|--config-dir <path>] [--force-moonraker <path>]"
    echo ""
    echo "Options:"
    echo "  -c, --config-dir       Path to Klipper configuration directory"
    echo "  --force-moonraker      Force a specific moonraker.conf path"
    echo "                         or force using fallback/detected config"
    echo "  -h, --help             Show this help message"
    exit 0
}

# ------------------------------------------------------------
# Helper: detect moonraker.conf
# ------------------------------------------------------------
detect_moonraker_conf() {
    echo "Detecting moonraker.conf location..." >&2

    local proc_line conf_path data_dir

    # ------------------------------------------------------------
    # 1) Running process
    # ------------------------------------------------------------
    if pgrep -f moonraker >/dev/null; then
        proc_line="$(ps aux | grep '[m]oonraker' | head -n 1)"

        # -c / --config
        conf_path="$(echo "$proc_line" | sed -n 's/.*-c \([^ ]*\).*/\1/p')"
        [ -z "$conf_path" ] && conf_path="$(echo "$proc_line" | sed -n 's/.*--config \([^ ]*\).*/\1/p')"

        if [ -n "$conf_path" ] && [ -f "$conf_path" ]; then
            echo "Found via running process (-c/--config): $conf_path" >&2
            echo "$conf_path"
            return 0
        fi

        # -d / --data-path
        data_dir="$(echo "$proc_line" | sed -n 's/.*-d \([^ ]*\).*/\1/p')"
        [ -z "$data_dir" ] && data_dir="$(echo "$proc_line" | sed -n 's/.*--data-path \([^ ]*\).*/\1/p')"

        if [ -n "$data_dir" ] && [ -f "$data_dir/moonraker.conf" ]; then
            echo "Found via running process (-d/--data-path): $data_dir/moonraker.conf" >&2
            echo "$data_dir/moonraker.conf"
            return 0
        fi
    fi

    # ------------------------------------------------------------
    # 2) systemd service
    # ------------------------------------------------------------
    if command -v systemctl >/dev/null 2>&1; then
        local service_dump
        service_dump="$(systemctl cat moonraker 2>/dev/null)"

        # -c / --config
        conf_path="$(echo "$service_dump" | sed -n 's/.*-c \([^ ]*\).*/\1/p' | head -n 1)"
        [ -z "$conf_path" ] && conf_path="$(echo "$service_dump" | sed -n 's/.*--config \([^ ]*\).*/\1/p' | head -n 1)"

        if [ -n "$conf_path" ] && [ -f "$conf_path" ]; then
            echo "Found via systemd (-c/--config): $conf_path" >&2
            echo "$conf_path"
            return 0
        fi

        # -d / --data-path
        data_dir="$(echo "$service_dump" | sed -n 's/.*-d \([^ ]*\).*/\1/p' | head -n 1)"
        [ -z "$data_dir" ] && data_dir="$(echo "$service_dump" | sed -n 's/.*--data-path \([^ ]*\).*/\1/p' | head -n 1)"

        if [ -n "$data_dir" ] && [ -f "$data_dir/moonraker.conf" ]; then
            echo "Found via systemd (-d/--data-path): $data_dir/moonraker.conf" >&2
            echo "$data_dir/moonraker.conf"
            return 0
        fi
    fi

    # ------------------------------------------------------------
    # 3) Fallbacks (only if valid)
    # ------------------------------------------------------------
    for fallback in \
        "$HOME/printer_data/config/moonraker.conf" \
        "$HOME/moonraker.conf"
    do
        if [ -f "$fallback" ] && grep -qE '^\s*\[server\]\s*$' "$fallback"; then
            echo "Using fallback (valid config): $fallback" >&2
            echo "$fallback"
            return 0
        fi
    done

    echo "No valid moonraker.conf found" >&2
    return 1
}

# ------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------
KLIPPER_CONF_DIR=""
INSTALL_ARGS=""
FORCE_MOONRAKER_CONF=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config-dir)
            KLIPPER_CONF_DIR="$2"
            INSTALL_ARGS="--config-dir $KLIPPER_CONF_DIR"
            shift 2
            ;;
        --force-moonraker)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                FORCE_MOONRAKER_CONF="$2"
                shift 2
            else
                FORCE_MOONRAKER_CONF="FORCE"
                shift 1
            fi
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# ------------------------------------------------------------
# Detect Klipper config directory
# ------------------------------------------------------------
if [ -n "$KLIPPER_CONF_DIR" ]; then
    echo "Using KLIPPER_CONF_DIR from argument: $KLIPPER_CONF_DIR"
    if [ ! -d "$KLIPPER_CONF_DIR" ]; then
        echo "Error: Provided KLIPPER_CONF_DIR does not exist"
        exit 1
    fi
else
    KLIPPER_CONF_DIR="${HOME}/printer_data/config"

    if [ ! -d "$KLIPPER_CONF_DIR" ]; then
        echo "New structure folder ~/printer_data not found, looking for a legacy structure..."

        if [ -d "$HOME/klipper_config" ]; then
            KLIPPER_CONF_DIR="${HOME}/klipper_config"
        elif [ -d "$HOME/printer_config" ]; then
            KLIPPER_CONF_DIR="${HOME}/printer_config"
        else
            KLIPPER_CONF_DIR="${HOME}"
        fi
    fi
fi

echo "Configuration files will be copied to: $KLIPPER_CONF_DIR"
echo ""

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ------------------------------------------------------------
# 1) Core config
# ------------------------------------------------------------
ln -sf "$REPO_DIR/goose_purge_core.cfg" "$KLIPPER_CONF_DIR/goose_purge_core.cfg"

# ------------------------------------------------------------
# 2) User config
# ------------------------------------------------------------
if [ -f "$KLIPPER_CONF_DIR/goose_purge.cfg" ]; then
    echo "User configuration file already exists and will not be overwritten"
else
    echo "User configuration file not found, default file will be copied"
    echo "What purger type would you like to configure?"
    echo "  1 - Belt purge with DC motor"
    echo "  2 - Belt purge with Stepper motor"
    read -p "Purger type: " purger_type

    if [[ "$purger_type" == "1" ]]; then
        cp "$REPO_DIR/goose_purge-dcmot.cfg" "$KLIPPER_CONF_DIR/goose_purge.cfg"
    elif [[ "$purger_type" == "2" ]]; then
        cp "$REPO_DIR/goose_purge-stpmot.cfg" "$KLIPPER_CONF_DIR/goose_purge.cfg"
    else
        echo "Invalid selection, configuration file not copied"
    fi
fi
echo ""

# ------------------------------------------------------------
# 3) Klipper python module
# ------------------------------------------------------------
echo "Installing klipper module"
EXTRAS_DIR="${HOME}/klipper/klippy/extras"

if [ -d "$EXTRAS_DIR" ]; then
    if [ -w "$EXTRAS_DIR" ]; then
        ln -sf "$REPO_DIR/goose_purge.py" "$EXTRAS_DIR/goose_purge.py"
    else
        sudo ln -sf "$REPO_DIR/goose_purge.py" "$EXTRAS_DIR/goose_purge.py"
    fi
else
    echo "Error: Klipper extras folder not found"
    exit 1
fi
echo ""

# ------------------------------------------------------------
# 4) Moonraker update manager
# ------------------------------------------------------------
echo "Configuring Moonraker update manager"

# Force handling
if [ -n "$FORCE_MOONRAKER_CONF" ] && [ "$FORCE_MOONRAKER_CONF" != "FORCE" ]; then
    echo "Forcing moonraker.conf path: $FORCE_MOONRAKER_CONF"
    MOONRAKER_CONF="$FORCE_MOONRAKER_CONF"
elif [ "$FORCE_MOONRAKER_CONF" = "FORCE" ]; then
    echo "Forcing use of detected or fallback moonraker.conf"
    MOONRAKER_CONF="$(detect_moonraker_conf || true)"
else
    MOONRAKER_CONF="$(detect_moonraker_conf || true)"
fi

SECTION_RAW="[update_manager goose_purge]"

# Validate config file
if [ -z "$MOONRAKER_CONF" ] || { [ ! -f "$MOONRAKER_CONF" ] && [ -z "$FORCE_MOONRAKER_CONF" ]; }; then
    echo "Warning: moonraker.conf not found, skipping update manager configuration"
else
    echo "Using moonraker.conf at: $MOONRAKER_CONF"

    # Backup before modifying
    BACKUP_FILE="$MOONRAKER_CONF.bak_$(date +%Y%m%d_%H%M%S)"
    cp "$MOONRAKER_CONF" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"

    # Remove existing block (robust, safe, NO regex)
if grep -qF "$SECTION_RAW" "$MOONRAKER_CONF"; then
    echo "Existing update manager section found — removing old block"

    TMP_FILE="$(mktemp)"
    inblock=0

    while IFS= read -r line || [ -n "$line" ]; do

        # Start of block
        if [ "$line" = "$SECTION_RAW" ]; then
            inblock=1
            continue
        fi

        # Next section starts → end block
        case "$line" in
            

\[*)
                if [ $inblock -eq 1 ]; then
                    inblock=0
                fi
                ;;
        esac

        # Only print lines outside the block
        if [ $inblock -eq 0 ]; then
            printf '%s\n' "$line" >> "$TMP_FILE"
        fi

    done < "$MOONRAKER_CONF"

    mv "$TMP_FILE" "$MOONRAKER_CONF"
fi



    echo "Writing fresh update manager configuration..."

    {
        echo ""
        echo "$SECTION_RAW"
        echo "type: git_repo"
        echo "primary_branch: beta"
        echo "path: ~/goose_purge_macro"
        echo "origin: https://github.com/Graylag-PD/Goose-Purge-Macro.git"
        echo "managed_services: klipper"
    } >> "$MOONRAKER_CONF"

    echo "Update manager configuration written successfully"
fi
