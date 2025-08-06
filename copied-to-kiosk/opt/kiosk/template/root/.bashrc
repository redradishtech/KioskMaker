# gsettings and friends should connect to 'kiosk' dbus (assumed to be running)
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
