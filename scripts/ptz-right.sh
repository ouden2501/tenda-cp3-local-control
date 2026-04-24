#!/bin/bash

CAM=$1
USER=admin
PASS=admin123456
PROFILE=profile_1

curl --digest -u "$USER:$PASS" \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\">
  <s:Body>
    <tptz:ContinuousMove xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\">
      <tptz:ProfileToken>$PROFILE</tptz:ProfileToken>
      <tptz:Velocity>
        <tt:PanTilt xmlns:tt=\"http://www.onvif.org/ver10/schema\" x=\"0.4\" y=\"0.0\"/>
      </tptz:Velocity>
    </tptz:ContinuousMove>
  </s:Body>
</s:Envelope>" \
  "http://$CAM/onvif/ptz_service"
