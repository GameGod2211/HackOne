#!/bin/bash

echo "
    ___     _                     _____ _____  
   / _ \ __| | ___ _ __ ___  ___ | ____|_   _| 
  | | | / _\` |/ _ \ '__/ _ \/ _ \|  _|   | |   
  | |_| | (_| |  __/ | |  __/  __/| |___  | |   
   \___/ \__,_|\___|_|  \___|\___||_____| |_|   

       ░█▀█░█░█░█░█░█▀█░█▀█░█▀▀
       ░█▀▄░█░█░█░█░█░█░█░█░█░█
       ░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
     OSINT Intelligence Toolkit

        👨‍💻 Coded by: Hacker Devil
"

# === Configuration ===
ABUSE_API_KEY="51ce390c1e5c5f1041c57ca31151b44a33bfdcee42ee957f59ef0ce7ea14bc3445986158111fb325"
IPINFO_API_KEY="a0ab2971-3381-41fe-bc90-d46db2d77bf6"

read -p "Enter an IP address or username: " TARGET
TS=$(date +"%Y%m%d_%H%M%S")
OUT_DIR="osint_scan_${TARGET}_$TS"
mkdir -p "$OUT_DIR"

# === IP Pattern Check ===
if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "📡 Scanning IP: $TARGET"

    # === AbuseIPDB Query ===
    echo "🔗 Querying AbuseIPDB..."
    ABUSE_RESPONSE=$(curl -sG "https://api.abuseipdb.com/api/v2/check" \
      --data-urlencode "ipAddress=$TARGET" \
      --data-urlencode "maxAgeInDays=90" \
      -H "Key: $ABUSE_API_KEY" \
      -H "Accept: application/json")

    echo "📊 AbuseIPDB Report:"
    echo "$ABUSE_RESPONSE" | jq '.data | {
        IP: .ipAddress,
        AbuseScore: .abuseConfidenceScore,
        Country: .countryCode,
        UsageType: .usageType,
        Domain: .domain,
        ISP: .isp,
        Hostnames: .hostnames,
        IsVPN: .isVpn,
        IsTorExitNode: .isTorExitNode,
        IsPublicProxy: .isPublicProxy,
        TotalReports: .totalReports,
        LastReportedAt: .lastReportedAt
    }'
    echo "$ABUSE_RESPONSE" > "$OUT_DIR/${TARGET}_abuseipdb.json"

    # VPN / Proxy / Tor Flags
    IS_VPN=$(echo "$ABUSE_RESPONSE" | jq -r '.data.isVpn')
    IS_TOR=$(echo "$ABUSE_RESPONSE" | jq -r '.data.isTorExitNode')
    IS_PROXY=$(echo "$ABUSE_RESPONSE" | jq -r '.data.isPublicProxy')

    echo -e "\n🛡️  VPN / Proxy / Tor Detection:"
    [ "$IS_VPN" == "true" ] && echo "🟠 VPN Detected"
    [ "$IS_PROXY" == "true" ] && echo "🔵 Public Proxy Detected"
    [ "$IS_TOR" == "true" ] && echo "🧅 Tor Exit Node Detected"
    if [ "$IS_VPN" == "false" ] && [ "$IS_PROXY" == "false" ] && [ "$IS_TOR" == "false" ]; then
        echo "✅ No VPN/Proxy/Tor detected"
    fi

    # === WHOIS ===
    echo -e "\n🌐 WHOIS Lookup:"
    WHOIS_OUTPUT=$(whois "$TARGET" | grep -Ei "OrgName|OrgId|Country|NetRange|CIDR|Name|address|descr")
    echo "$WHOIS_OUTPUT" > "$OUT_DIR/${TARGET}_whois.txt"
    echo "$WHOIS_OUTPUT"

    # === IPInfo ===
    echo -e "\n🌍 IPInfo Lookup:"
    IPINFO_RESPONSE=$(curl -s "https://ipinfo.io/$TARGET?token=$IPINFO_API_KEY")
    echo "$IPINFO_RESPONSE" | jq '{
        IP: .ip,
        City: .city,
        Region: .region,
        Country: .country,
        Location: .loc,
        Org: .org,
        ASN: .asn,
        Timezone: .timezone
    }'
    echo "$IPINFO_RESPONSE" > "$OUT_DIR/${TARGET}_ipinfo.json"

    # Google Maps
    GEOLOC=$(echo "$IPINFO_RESPONSE" | jq -r '.loc')
    MAP_URL="https://www.google.com/maps?q=$GEOLOC"
    echo "📍 View location: $MAP_URL"
    if command -v xdg-open >/dev/null; then xdg-open "$MAP_URL"
    elif command -v open >/dev/null; then open "$MAP_URL"; fi

else
    echo "🧑‍💻 Scanning Username: $TARGET"

    if ! command -v maigret &>/dev/null; then
        echo "❌ Maigret not installed. Run: pip install maigret"
        exit 1
    fi

    maigret "$TARGET" --format json --output "$OUT_DIR/${TARGET}_maigret.json"
    echo "✅ Maigret scan complete. Saved to $OUT_DIR/${TARGET}_maigret.json"
fi

echo -e "\n📁 Scan completed. Results saved in: $OUT_DIR"
