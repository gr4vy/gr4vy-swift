#!/usr/bin/env bash
# Prepare one QA case in gr4vy-swift-client-app on the booted simulator.
#
# Creates a fresh sandbox checkout session, writes the app's settings (token, Gr4vy ID,
# session, card, Authenticate, preferred scheme) and relaunches the app with its console
# captured to $QA_LOG. Then open Tokenize in the app and tap PUT.
#
# Usage: QA_LOG=case1.log scripts/qa/ios-seed.sh <currency> <card_number> <cvv> [preferred_scheme] [authenticate]
#   QA_LOG=case2.log scripts/qa/ios-seed.sh EUR 4556557955726624 123 visa true
#
# Needs the gr4vy CLI with an active sandbox profile and the client app installed on the
# booted simulator. Never prints the token.
set -euo pipefail

CURRENCY=$1; PAN=$2; CVV=$3; PREFERRED=${4:-}; AUTHENTICATE=${5:-true}
APP=app.gr4vy.Gr4vy-SwiftUI-Sample-App
xcrun simctl get_app_container booted "$APP" > /dev/null || { echo "$APP isn't installed on a booted simulator" >&2; exit 1; }
ID=$(gr4vy config show | awk '$1=="id"{print $2}')
MERCHANT=$(gr4vy config show | awk '$1=="merchant_account_id"{print $2}')
[ "$(gr4vy config show | awk '$1=="environment"{print $2}')" = "sandbox" ] || { echo "Sandbox profiles only" >&2; exit 1; }

SESSION=$(gr4vy checkout-sessions create --compact \
  --data "{\"amount\":1299,\"currency\":\"$CURRENCY\",\"country\":\"GB\"}" |
  python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')

xcrun simctl terminate booted "$APP" 2>/dev/null || true
w() { xcrun simctl spawn booted defaults write "$APP" "$@"; }
w gr4vyId -string "$ID"
w merchantId -string "${MERCHANT:-default}"
w serverEnvironment -string sandbox
w apiToken -string "$(gr4vy token -e 2h)"
w fields_checkout_session_id -string "$SESSION"
w fields_payment_method_type -string card
w fields_test_card -string custom
w fields_card_number -string "$PAN"
w fields_expiration_date -string "01/30"
w fields_security_code -string "$CVV"
w fields_authenticate -bool "$AUTHENTICATE"
w fields_preferred_scheme -string "$PREFERRED"

nohup xcrun simctl launch --console-pty --terminate-running-process booted "$APP" > "${QA_LOG:-/dev/null}" 2>&1 &
LAUNCH=$!
sleep 2
kill -0 "$LAUNCH" 2>/dev/null || { echo "App launch failed${QA_LOG:+, see $QA_LOG}" >&2; exit 1; }
echo "session=$SESSION currency=$CURRENCY card=${PAN:0:6}… preferred='$PREFERRED' authenticate=$AUTHENTICATE log=${QA_LOG:-none}"
