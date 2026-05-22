# (this script is for bash)

# From: https://people.debian.org/~mpitt/systemd.conf-2016-graphical-session.pdf

# If the previous graphical session left some failed units, reset
# them so that they don't break this startup.
for unit in $(systemctl --user --no-legend --state=failed --plain list-units | cut -f1 -d' '); do
    partof="$(systemctl --user show -p PartOf --value "$unit")"
    for target in river-session.target graphical-session.target; do
	    if [ "$partof" = "$target" ]; then
			systemctl --user reset-failed "$unit"
			break
	    fi
    done
done

# Save environment variables that will be added to systemd.
new_env=$(systemctl --user show-environment | cut -d'=' -f 1 | sort | comm -13 - <(env | cut -d'=' -f 1 | sort))

# Import environment variables from the login manager.
systemctl --user import-environment
systemctl --user import-environment PATH

# Start the service.
systemctl --wait --user start river.service

# Cleanup environment.
systemctl --user unset-environment $new_env

exit 0
