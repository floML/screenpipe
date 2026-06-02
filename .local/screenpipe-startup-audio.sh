#!/bin/bash
# screenpipe — AI that knows everything you've seen, said, or heard
# https://screenpi.pe
# Local development startup script — audio enabled variant (not tracked in git)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Prefer in-bundle binary (set by wrapper) so TCC attributes to the .app.
SCREENPIPE="${SCREENPIPE_BINARY:-$SCRIPT_DIR/../target/release/screenpipe}"

exec "$SCREENPIPE" record \
  --disable-clipboard-capture \
  `# Don't capture clipboard text (privacy/security)` \
  --encrypt-secrets \
  `# Encrypt sensitive data like passwords in storage` \
  -a whisper-large-v3-turbo \
  `# Use Whisper Turbo model for fast, accurate speech-to-text` \
  --use-system-default-audio \
  `# Follow the system default mic — triggers TCC mic prompt on first run` \
  --retention-days 1 \
  `# Keep recordings for 1 day, then auto-delete` \
  --disable-telemetry \
  `# Don't send telemetry data back to Screenpipe servers` \
  --disable-vision #\
  `# Disable vision/screenshot capture for lower memory usage.` \
  # --disable-meeting-detector \
  # `# Disable auto-detection (Webex running in bg would block transcription)` \
