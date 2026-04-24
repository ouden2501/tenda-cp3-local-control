# Tenda CP3 Local Control (RTSP + ONVIF, No Cloud)

## Overview

This project demonstrates how a low-cost consumer IP camera (Tenda CP3) can be fully controlled locally without using the vendor cloud.

We identified and tested:

* RTSP video streaming
* ONVIF PTZ control
* local service exposure
* security limitations

## Key Findings

* RTSP stream available:
  rtsp://admin:admin123456@<IP>:554/tenda

* ONVIF fully functional:

  * PTZ control works
  * media and device services available

* HTTP interface:

  * redirects to HTTPS
  * no usable web UI

* User management:

  * GetUsers returns empty
  * SetUser accepted but ineffective
  * credentials effectively unchanged

## Quick Start

### Test RTSP stream

ffplay "rtsp://admin:admin123456@<IP>:554/tenda"

### Move camera (example)

Use ONVIF or curl (see scripts below)

## Architecture

Camera (RTSP + ONVIF)
↓
Local node (Raspberry Pi / server)
↓
Tailscale
↓
Remote access

## Security Notes

* Default credentials remain active
* No TLS for ONVIF
* RTSP unencrypted
* No reliable password change mechanism

→ Treat the device as untrusted

## Scripts

See /scripts folder for:

* RTSP test
* PTZ control via curl
* ONVIF checks

## Conclusion

The Tenda CP3 is not a "cloud-only" device.

It exposes standard protocols that allow:

* full local video access
* full PTZ control

However, security and user management are incomplete.

## Future Work

* Backend proxy (RTSP + ONVIF)
* Android control app
* multi-camera management
* network isolation architecture

