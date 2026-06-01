#!/bin/bash
# screenpipe — AI that knows everything you've seen, said, or heard
# https://screenpi.pe
# Local development startup script (not tracked in git)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCREENPIPE="$SCRIPT_DIR/../target/release/screenpipe"

exec "$SCREENPIPE" record \
  --disable-clipboard-capture \
  `# Don't capture clipboard text (privacy/security)` \
  --disable-audio \
  `# Don't record audio (privacy/performance)` \
  --encrypt-secrets \
  `# Encrypt sensitive data like passwords in storage` \
#   --async-pii-redaction \
#   `# Redact PII (phone numbers, emails, etc.) asynchronously to avoid blocking` \
#   --ignored-windows "1Password" \
#   `# Ignore password manager window content` \
#   --ignored-windows "Bitwarden" \
#   `# Ignore password manager window content` \
#   --ignored-windows "Keychain Access" \
#   `# Ignore system keychain window content` \
  -a whisper-large-v3-turbo \
  `# Use Whisper Turbo model for fast, accurate speech-to-text` \
  --retention-days 14 \
  `# Keep recordings for 14 days, then auto-delete` \
  --disable-telemetry \
  `# Don't send telemetry data back to Screenpipe servers` \
  --disable-vision \
  `# Disable vision/screenshot capture for lower memory usage.` \
  --disable-meeting-detector \
  `# Disable auto-detection (Webex running in bg would block transcription)` \

# Other important screenpipe options:
# --budget-tokens N          Limit tokens in LLM context (default: 10000)
# --unstructured             Use OCR instead of accessibility tree
# --vision-engine VISION_ENGINE  (openai, claude, gemini, ollama)
# --chunk-size N             Chunk size for storage (default: 256)
# --chunk-overlap N          Chunk overlap percentage (default: 20)
# --interval-ms N            Sampling interval in ms (default: 10000)
# --ignore-list FILE         File with patterns to ignore
# --disable-vision           Disable vision/screenshot capture
# --max-quality N            Reduce quality to lower resource usage
