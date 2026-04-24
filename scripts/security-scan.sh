#!/bin/bash

CAM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$CAM" ]; then
  echo "Usage: $0 <camera_ip>"
  exit 1
fi

echo "======================================"
echo " Tenda CP3 Security Evidence Report"
echo " Target: $CAM"
echo " Date: $(date)"
echo "======================================"
echo

echo "[1] Open TCP ports"
echo "--------------------------------------"
nmap -p- --open -T4 "$CAM" | awk '
/^[0-9]+\/tcp/ { print " - " $1 " " $2 " " $3 }
'
echo

echo "[2] Service detection"
echo "--------------------------------------"
nmap -sV -p 22,23,80,443,554,8000 "$CAM" | awk '
/^[0-9]+\/tcp/ { print " - " $1 " " $2 " " $3 " " $4 " " $5 " " $6 }
'
echo

echo "[3] HTTP behavior"
echo "--------------------------------------"
HTTP_CODE=$(curl -s -o /tmp/tenda_http_body.txt -D /tmp/tenda_http_headers.txt --max-time 5 "http://$CAM/" | true)
grep -E "HTTP/|Location:|Server:" /tmp/tenda_http_headers.txt 2>/dev/null | sed 's/^/ - /'
BODY=$(cat /tmp/tenda_http_body.txt 2>/dev/null)
[ -n "$BODY" ] && echo " - Body: $BODY"
echo

echo "[4] HTTPS behavior"
echo "--------------------------------------"
if curl -k -s -i --max-time 5 "https://$CAM/" >/tmp/tenda_https.txt 2>/dev/null; then
  grep -E "HTTP/|Server:" /tmp/tenda_https.txt | sed 's/^/ - /'
else
  echo " - HTTPS not reachable on port 443"
fi
echo

echo "[5] RTSP default credentials"
echo "--------------------------------------"
if ffprobe -v error -rtsp_transport tcp "rtsp://admin:admin123456@$CAM:554/tenda" >/dev/null 2>&1; then
  echo " - RESULT: WORKING"
  echo " - URL: rtsp://admin:admin123456@$CAM:554/tenda"
else
  echo " - RESULT: FAILED"
fi
echo

echo "[6] ONVIF evidence"
echo "--------------------------------------"
if [ -f "$SCRIPT_DIR/security/onvif-info.py" ]; then
  /opt/onvif-venv/bin/python "$SCRIPT_DIR/security/onvif-info.py" "$CAM"
else
  echo " - Missing helper: $SCRIPT_DIR/security/onvif-info.py"
fi

rm -f /tmp/tenda_http_body.txt /tmp/tenda_http_headers.txt /tmp/tenda_https.txt
