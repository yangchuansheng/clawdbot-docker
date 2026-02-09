#!/bin/bash
node /home/openclaw/auto-approve.js &
exec openclaw gateway --allow-unconfigured --bind lan
