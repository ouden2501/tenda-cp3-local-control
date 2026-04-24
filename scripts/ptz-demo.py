#!/usr/bin/env python3

import argparse
import time
from onvif import ONVIFCamera

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--camera", required=True)
    parser.add_argument("-u", "--user", default="admin")
    parser.add_argument("-p", "--password", default="admin123456")
    parser.add_argument("--profile", default="main", choices=["main", "sub"])
    parser.add_argument("-s", "--speed", type=float, default=0.2)
    parser.add_argument("-t", "--time", type=float, default=0.5)
    parser.add_argument("-w", "--wait", type=float, default=0.3)
    args = parser.parse_args()

    cam = ONVIFCamera(args.camera, 80, args.user, args.password)
    media = cam.create_media_service()
    ptz = cam.create_ptz_service()

    profiles = media.GetProfiles()
    profile = profiles[0] if args.profile == "main" else profiles[1]

    def stop():
        req = ptz.create_type("Stop")
        req.ProfileToken = profile.token
        req.PanTilt = True
        req.Zoom = True
        ptz.Stop(req)

    def move(x, y, label):
        print(f"Move: {label}")
        req = ptz.create_type("ContinuousMove")
        req.ProfileToken = profile.token
        req.Velocity = {
            "PanTilt": {"x": x, "y": y},
            "Zoom": {"x": 0.0},
        }
        ptz.ContinuousMove(req)
        time.sleep(args.time)
        stop()
        time.sleep(args.wait)

    print(f"Camera: {args.camera}")
    print(f"Profile: {profile.token}")
    print("Press CTRL+C to stop")

    try:
        while True:
            move(0.0, -args.speed, "down")
            move(0.0, args.speed, "up")
            move(-args.speed, 0.0, "left")
            move(args.speed, 0.0, "right")
    except KeyboardInterrupt:
        print("\nStopping camera...")
        stop()

if __name__ == "__main__":
    main()
