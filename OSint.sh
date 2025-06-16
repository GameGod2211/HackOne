#!/bin/bash
# HawkScan Lite with Dashboard UI
# Hack - One | Coded by: Hacker Devil

# Check dependencies
for cmd in curl jq dialog xargs; do
  if ! command -v $cmd &>/dev/null; then
    echo "⚠️ Please install '$cmd' to run this tool."
    exit 1
  fi
done

# -- Banner --
cat <<'BANNER'
██╗  ██╗ █████╗  ██████╗██╗  ██╗     ██████╗ ███╗   ██╗███████╗
██║  ██║██╔══██╗██╔════╝██║ ██╔╝    ██╔═══██╗████╗  ██║██╔════╝
███████║███████║██║     █████╔╝     ██║   ██║██╔██╗ ██║█████╗  
██╔══██║██╔══██║██║     ██╔═██╗     ██║   ██║██║╚██╗██║██╔══╝  
██║  ██║██║  ██║╚██████╗██║  ██╗    ╚██████╔╝██║ ╚████║███████╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝v1
Coded by Hacker Devil 
         ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          HAWKSCAN LITE - OSINT TOOL
         Hack - One  |  Hacker Devil
         ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BANNER

# -- Setup --
read -p "🔍 Enter username to scan: " USERNAME
TS=$(date +"%Y%m%d_%H%M%S")
OUT_DIR="hawkscan_${USERNAME}_$TS"
FOUND="$OUT_DIR/found.txt"
JSON="$OUT_DIR/results.json"
mkdir -p "$OUT_DIR"

SITES=(
  "https://github.com/$USERNAME"
  "https://twitter.com/$USERNAME"
  "https://instagram.com/$USERNAME"
  "https://reddit.com/user/$USERNAME"
  "https://www.tiktok.com/@$USERNAME"
  "https://www.pinterest.com/$USERNAME"
  "https://www.deviantart.com/$USERNAME"
  "https://www.producthunt.com/@$USERNAME"
  "https://www.quora.com/profile/$USERNAME"
  "https://www.behance.net/$USERNAME"
  "https://www.kaggle.com/$USERNAME"
  "https://soundcloud.com/$USERNAME"
  "https://www.twitch.tv/$USERNAME"
  "https://steamcommunity.com/id/$USERNAME"
  "https://medium.com/@$USERNAME"
  "https://keybase.io/$USERNAME"
  "https://stackoverflow.com/users/$USERNAME"
)

check_site() {
  local URL="$1"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [[ "$STATUS" =~ ^(200|301|302)$ ]]; then
    echo "✅ $URL" >> "$FOUND"
    curl -s "$URL" > "$OUT_DIR/$(echo "$URL" | sed 's/[^A-Za-z0-9]/_/g').html"
  fi
}

# -- Run Scan --
printf "%s\n" "${SITES[@]}" | xargs -n1 -P10 -I {} bash -c 'check_site "$@"' _ {}

# -- Build JSON Summary --
if [ -s "$FOUND" ]; then
  jq -Rn --slurpfile urls "$FOUND" '{"username":"'"$USERNAME"'", "matches":$urls[0]}' > "$JSON"
else
  echo '{"username":"'"$USERNAME"'", "matches":[]}' > "$JSON"
fi

# -- Dashboard Menu --
while true; do
  CMD=$(dialog --clear --backtitle "Hack - One" \
    --title "HawkScan Lite Dashboard" \
    --menu "Username: $USERNAME" 15 60 4 \
    1 "Show Found URLs" \
    2 "View HTML Files" \
    3 "View JSON Report" \
    4 "Exit" \
    2>&1 >/dev/tty)

  case $CMD in
    1)
      dialog --backtitle "Found Results" --title "Found URLs" --textbox "$FOUND" 20 60;;
    2)
      FILE=$(ls "$OUT_DIR"/*.html | dialog --backtitle "HTML Files" --title "Select HTML" --menu "Choose file to view:" 15 60 10 2>&1 >/dev/tty)
      [ "$FILE" ] && dialog --backtitle "View HTML" --title "$FILE" --textbox "$FILE" 20 60;;
    3)
      dialog --backtitle "JSON Report" --title "Report Content" --textbox "$JSON" 20 60;;
    4)
      clear; echo "👋 Exiting HawkScan Lite."; exit 0;;
    *)
      ;;
  esac
done
