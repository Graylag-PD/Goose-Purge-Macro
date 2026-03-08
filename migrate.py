import os
import sys

SOURCE_FILE = "goose_belt.cfg"
TARGET_FILE = "goose_purge.cfg"

VARIABLES_TO_COPY = [
    "pin",
    "variable_start_with_stage",
    "variable_x_stage",
    "variable_y_stage",
    "variable_z_stage",
    "variable_th_to_stage",
    "variable_x_purge",
    "variable_y_purge",
    "variable_z_purge",
    "variable_th_to_purge",
    "variable_belt_pwm",
    "variable_belt_kickstart",
    "variable_time_kickstart",
    "variable_control_fan",
    "variable_fan_speed",
    "variable_extrusion_fr",
    "variable_retraction_fr",
    "variable_deretraction_fr",
    "variable_extrusion_min",
    "variable_extrusion_max",
    "variable_retraction",
    "variable_roundup",
    "variable_default_purge_volume",
    "variable_rtr_dwell",
    "variable_belt_pwm_dwell",
    "variable_slowdown_dwell",
    "variable_deretraction",
    "variable_final_retraction",
    "variable_final_retraction_fr",
    "variable_pressure_release_dwell",
    "variable_end_with_stage",
    "variable_restore_z",
    "variable_th_z_restore",
    "variable_time_belt_stop",
    "variable_belt_pwm_end",
    "variable_user_end_script"
    
]


def load_values(file_path, variables):
    """Load values from the old macro"""
    values = {}

    try:
        with open(file_path, "r") as f:
            for line in f:
                stripped = line.strip()

                if not stripped or stripped.startswith(("#", ";")):
                    continue

                if ":" not in stripped:
                    continue

                key, value = stripped.split(":", 1)
                key = key.strip()
                value = value.strip()

                if key in variables:
                    values[key] = value

    except FileNotFoundError:
        print(f"File not found: {file_path}")
        sys.exit(1)

    return values


def update_target(file_path, updates):
    """Update new macro."""
    try:
        with open(file_path, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        sys.exit(1)

    found = set()
    new_lines = []

    for line in lines:
        stripped = line.strip()

        if ":" in stripped and not stripped.startswith(("#", ";")):
            key, value = stripped.split(":", 1)
            key = key.strip()

            if key in updates:
                indent = line[:len(line) - len(line.lstrip())]
                line = f"{indent}{key}: {updates[key]}\n"
                found.add(key)

        new_lines.append(line)

    missing = set(updates.keys()) - found
    if missing:
        print("Variables NOT found in new macro:", ", ".join(missing))

    with open(file_path, "w") as f:
        f.writelines(new_lines)


def main(cfg_dir):
    source_path = os.path.join(cfg_dir, SOURCE_FILE)
    target_path = os.path.join(cfg_dir, TARGET_FILE)

    values = load_values(source_path, VARIABLES_TO_COPY)

    if not values:
        print("No variables updated.")
        return

    update_target(target_path, values)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Use: python migrate.py <folder>")
        sys.exit(1)

    main(sys.argv[1])