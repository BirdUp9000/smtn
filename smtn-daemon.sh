#!/bin/bash

#                           __
#         _____ ____ ___   / /_ ____
#        / ___// __ `__ \ / __// __ \
#       (__  )/ / / / / // /_ / / / /
#      /____//_/ /_/ /_/ \__//_/ /_/
#                              
#     Simple Mail Terminal Notifier
#
#     This script is a simple terminal-based mail notifier.
#     It checks multiple email inboxes via IMAP over SSL,
#     and reports the number of unread (unseen) messages.
#
#     Author: Artem Romanov https://github.com/BirdUp9000



# Check OpenSSL.
command -v openssl >/dev/null || { echo "OpenSSL not found"; exit 1; }

# Reading/Creating config file.
CONFIG_DIRECTORY="$HOME/.config/smtn"
CONFIG_FILE="$CONFIG_DIRECTORY/config"
OUTPUT_DIRECTORY="$HOME/.cache/smtn"
OUTPUT_FILE="$OUTPUT_DIRECTORY/mail"

# Creating files.
if [[ ! -f "$OUTPUT_FILE" ]]; then
  mkdir -p "$OUTPUT_DIRECTORY"
  touch "$OUTPUT_FILE"
fi

  if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$CONFIG_DIRECTORY"

    cat <<EOF > "$CONFIG_FILE"
#                           __                                ____ _
#         _____ ____ ___   / /_ ____     _____ ____   ____   / __/(_)____ _
#        / ___// __ \__ \ / __// __ \   / ___// __ \ / __ \ / /_ / // __ \`
#       (__  )/ / / / / // /_ / / / /  / /__ / /_/ // / / // __// // /_/ /
#      /____//_/ /_/ /_/ \__//_/ /_/   \___/ \____//_/ /_//_/  /_/ \__, /
#                                                                 /____/
#     Simple Mail Terminal Notifier Configuration File
#



# Refresh rate in seconds. 10m by default.
MAILBOX_REFRESH_RATE=600

# Add your Gmail information
SMTN_GMAIL_IMAP="imap.gmail.com:993"
SMTN_GMAIL_LOGIN=""
SMTN_GMAIL_APP_PASSWORD=""

# You can paste additional information about other e-mail boxes.
# Just copy IMAP, LOGIN and PASSWORD fields and fill them with
# your information like that.

SMTN_YAHOO_IMAP="imap.mail.yahoo.com:993"
SMTN_YAHOO_LOGIN=""
SMTN_YAHOO_APP_PASSWORD=""

SMTN_OUTLOOK_IMAP="imap-mail.outlook.com:993"
SMTN_OUTLOOK_LOGIN=""
SMTN_OUTLOOK_APP_PASSWORD=""

SMTN_ICloud_IMAP="imap.mail.me.com:993"
SMTN_ICloud_LOGIN=""
SMTN_ICloud_APP_PASSWORD=""

SMTN_GMX_IMAP="imap.gmx.com:993"
SMTN_GMX_LOGIN=""
SMTN_GMX_APP_PASSWORD=""

SMTN_PROTON_IMAP="imap.protonmail.com:993"
SMTN_PROTON_LOGIN=""
SMTN_PROTON_APP_PASSWORD=""

SMTN_YANDEX_IMAP="imap.yandex.ru:993"
SMTN_YANDEX_LOGIN=""
SMTN_YANDEX_APP_PASSWORD=""

SMTN_MAILRU_IMAP="imap.mail.ru:993"
SMTN_MAILRU_LOGIN=""
SMTN_MAILRU_APP_PASSWORD=""
EOF
fi

# Main loop.
while true; do

  # Hooking up config file.
  if ! source "$CONFIG_FILE" 2>/dev/null; then
    echo "Error: Failed to load config."
    exit 1
  fi

  # Getting user-provided info.
  declare -i new_mail=0
  IMAP=""
  LOGIN=""
  PASS=""

  declare -i checked_mailboxes=0

  for var in $(compgen -v); do
    if [[ "$var" == SMTN_*_IMAP ]]; then
      IMAP="${!var}"
    elif [[ "$var" == SMTN_*_LOGIN ]]; then
      LOGIN="${!var}"
    elif [[ "$var" == SMTN_*_PASSWORD ]]; then
      PASS="${!var}"
    fi

    if [[ -n "$IMAP" && -n "$LOGIN" && -n "$PASS" ]]; then
      # Fetching mailbox data.
      imap_cmds=$(printf "a LOGIN %s %s\na STATUS INBOX (UNSEEN)\na LOGOUT\n" "$LOGIN" "$PASS")
      output=$(echo "$imap_cmds" | openssl s_client -crlf -quiet -connect "$IMAP" 2>/dev/null)
      result=$(echo "$output" | grep 'STATUS "INBOX"' | grep -oE '[0-9]+')

      if [[ "$result" =~ ^[0-9]+$ ]]; then
        new_mail+=$result
      fi

      IMAP=""
      LOGIN=""
      PASS=""

      ((checked_mailboxes++))
    fi
  done

  if [[ "$checked_mailboxes" -ne 0 ]]; then
    printf "%i Mailboxes : %i Mail.\n" "$checked_mailboxes" "$new_mail" > "$OUTPUT_FILE"
  else
    printf "No mailboxes were checked.\n" > "$OUTPUT_FILE"
  fi

  MAILBOX_REFRESH_RATE=${MAILBOX_REFRESH_RATE:-600}
  sleep $MAILBOX_REFRESH_RATE

done

