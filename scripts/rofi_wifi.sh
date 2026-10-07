#!/usr/bin/env bash
# rofi-wifi — sway + rofi wifi picker
# Deps: NetworkManager (nmcli), rofi, a Nerd Font for glyphs, notify-send (optional)

set -euo pipefail

notify() { command -v notify-send >/dev/null && notify-send "Wi-Fi" "$1" || echo "$1"; }

ROFI_WIDTH='window {width: 500px;}'

# --- Helpers -----------------------------------------------------------------

wait_for_wifi_ready() {
  # After `radio wifi on`, the device takes a moment to leave "unavailable".
  for _ in {1..20}; do
    if nmcli -t -f DEVICE,TYPE,STATE device |
      awk -F: '$2=="wifi" && $3!="unavailable" && $3!="unmanaged"{f=1} END{exit !f}'; then
      return 0
    fi
    sleep 0.15
  done
  return 1
}

rescan() {
  nmcli device wifi rescan >/dev/null 2>&1 || true
  # Results populate asynchronously; give the cache a moment to fill.
  sleep 1.2
}

list_networks() {
  # Emit formatted rows sorted by signal ASCENDING (weakest first).
  nmcli --terse --fields IN-USE,SSID,SECURITY,SIGNAL device wifi list --rescan no |
    awk -F: '$2 != "" {
        key=$2
        if (!(key in seen) || $4+0 > sig[key]) { seen[key]=$0; sig[key]=$4+0 }
      } END { for (k in seen) print seen[k] }' |
    sort -t: -k4 -n |
    awk -F: '{
        sig = $4 + 0
        secured = ($3 != "" && $3 != "--")
        if (secured) {
          if      (sig >= 75) icon = "󰤪"
          else if (sig >= 50) icon = "󰤧"
          else if (sig >= 25) icon = "󰤤"
          else if (sig >=  1) icon = "󰤡"
          else                icon = "󰤬"
        } else {
          if      (sig >= 75) icon = "󰤨"
          else if (sig >= 50) icon = "󰤥"
          else if (sig >= 25) icon = "󰤢"
          else if (sig >=  1) icon = "󰤟"
          else                icon = "󰤯"
        }
        inuse = ($1 == "*") ? "󰸞 " : "  "
        printf "%s %s  %s  (%s%%)\n", inuse, icon, $2, sig
      }'
}

extract_ssid() {
  # Row format: "<inuse-marker>  <signal-icon>  <SSID>  (NN%)"
  local row="$1" tmp
  tmp="${row%  (*%)}"       # strip trailing "  (NN%)"
  printf '%s' "${tmp##*  }" # everything after the last "  "
}

active_ssid() {
  nmcli -t -f ACTIVE,SSID device wifi | awk -F: '$1=="yes"{print $2; exit}'
}

wifi_device() {
  nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}'
}

# --- Actions -----------------------------------------------------------------

connect_ssid() {
  local ssid="$1" security

  # Saved profile? Just bring it up.
  if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    if nmcli connection up "$ssid" >/dev/null 2>&1; then
      notify "Connected to $ssid"
      return 0
    fi
    # Fall through if stored creds failed.
  fi

  security=$(nmcli --terse --fields SSID,SECURITY device wifi list |
    awk -F: -v s="$ssid" '$1 == s { print $2; exit }')

  if [ -z "$security" ] || [ "$security" = "--" ]; then
    nmcli device wifi connect "$ssid" >/dev/null 2>&1 &&
      notify "Connected to $ssid" ||
      notify "Failed to connect to $ssid"
  else
    local password
    password=$(rofi -dmenu -password -p "Password for $ssid" </dev/null || true)
    [ -z "${password:-}" ] && return 0
    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
      notify "Connected to $ssid"
    else
      notify "Failed to connect to $ssid (wrong password?)"
    fi
  fi
}

disconnect_active() {
  local ssid="$1" dev
  dev=$(wifi_device)
  if [ -z "$dev" ]; then
    notify "No Wi-Fi device found"
    return 1
  fi
  if nmcli device disconnect "$dev" >/dev/null 2>&1; then
    notify "Disconnected from $ssid"
  else
    notify "Failed to disconnect"
  fi
}

# --- Menus -------------------------------------------------------------------

disabled_menu() {
  # Loop so Rescan/Enable keep the UI open.
  while :; do
    local state chosen
    state=$(nmcli -t -f WIFI radio)
    [ "$state" = "enabled" ] && return 0

    chosen=$(printf '󰖩  Enable Wi-Fi\n󰑐  Rescan\n󰅖  Cancel' |
      rofi -dmenu -i -p "Wi-Fi (off)" -theme-str "$ROFI_WIDTH" || true)
    [ -z "${chosen:-}" ] && exit 0

    case "$chosen" in
    *"Enable Wi-Fi"*)
      nmcli radio wifi on
      notify "Wi-Fi enabled, scanning..."
      wait_for_wifi_ready || true
      rescan
      return 0
      ;;
    *"Rescan"*)
      # Rescanning while wifi is off doesn't do much, but honour the ask:
      # turn it on briefly? No — just re-prompt. User can hit Enable.
      notify "Enable Wi-Fi first to scan"
      ;;
    *)
      exit 0
      ;;
    esac
  done
}

main_menu() {
  # Loop so disconnect/rescan actions keep the UI open.
  while :; do
    local state
    state=$(nmcli -t -f WIFI radio)
    if [ "$state" != "enabled" ]; then
      disabled_menu
      continue
    fi

    local networks menu chosen
    mapfile -t networks < <(list_networks)

    if [ ${#networks[@]} -eq 0 ]; then
      menu=$'󰖪  Disable Wi-Fi\n󰑐  Rescan\n󰅖  Cancel'
    else
      # Networks are already weakest -> strongest.
      menu=$'󰖪  Disable Wi-Fi\n󰑐  Rescan\n'"$(printf '%s\n' "${networks[@]}")"
    fi

    chosen=$(printf '%s' "$menu" | rofi -dmenu -i -p "Wi-Fi" -theme-str "$ROFI_WIDTH" || true)
    [ -z "${chosen:-}" ] && exit 0

    case "$chosen" in
    *"Disable Wi-Fi"*)
      nmcli radio wifi off && notify "Wi-Fi disabled"
      continue
      ;;
    *"Rescan"*)
      notify "Rescanning..."
      rescan
      continue
      ;;
    *"Cancel"*)
      exit 0
      ;;
    esac

    local ssid current
    ssid=$(extract_ssid "$chosen")
    current=$(active_ssid)

    if [ -n "$ssid" ] && [ "$ssid" = "$current" ]; then
      disconnect_active "$ssid"
      # Keep the UI running so another network can be picked.
      continue
    fi

    connect_ssid "$ssid"
    # After a connect attempt, loop back so the user sees the updated state
    # (checkmark on the newly connected network) and can pick again if wanted.
  done
}

# --- Entry point -------------------------------------------------------------

# Kick off an initial scan if wifi is already on, so the first menu is fresh.
if [ "$(nmcli -t -f WIFI radio)" = "enabled" ]; then
  nmcli device wifi rescan >/dev/null 2>&1 &
fi

main_menu
