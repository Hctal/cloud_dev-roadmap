
#!/usr/bin/env bash

URL="${1:-http://127.0.0.1:8000}"

echo "===== SERVER HEALTH CHECK ====="
echo "Checking: $URL"

# Check HTTP availability
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is not installed"
    exit 2
fi

HTTP_CODE=$(curl -sS -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout 2 \
    --max-time 5 "$URL" 2>/dev/null) || HTTP_CODE="000"

if [[ "$HTTP_CODE" =~ ^2[0-9][0-9]$ ]]; then
    echo "Application status: HEALTHY"
    echo "HTTP status: $HTTP_CODE"
else
    echo "Application status: UNHEALTHY"
    echo "HTTP status: $HTTP_CODE"
fi

# Check disk usage
echo ""
echo "Disk usage:"
df -h /

echo "===== CHECK COMPLETED ====="
