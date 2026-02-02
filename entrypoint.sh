#!/bin/bash
set -euo pipefail

node /home/devbox/project/auto-approve.js &
exec openclaw gateway --allow-unconfigured --bind lan
