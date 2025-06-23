# ✉️ SMTN - Simple Mail Terminal Notification
**SMTN** is a lightweight Bash script that periodically checks your email inboxes via IMAP over SSL and displays the number of unread messages every time you open a new terminal session.

## 📦 Dependencies
- bash
- OpenSSL

## ✨ Features
- Works with multiple mail providers (Gmail, Yahoo, Outlook, etc.)
- Uses secure IMAP over SSL
- Background daemon with configurable refresh interval
- Displays unread message count on terminal startup
- Pure Bash + OpenSSL – no extra dependencies

## 🛠️ Installation
1. Copy ```smtn-daemon.sh``` into ```~/bin```.
2. Make it executable ```sudo chmod +x ~/bin/smtn-daemon.sh```.
3. Start the daemon at login: Add this to your ```~/.bashrc``` or ```~/.bash_profile```: <br> ```pgrep -f smtn-daemon.sh > /dev/null || nohup ~/bin/smtn-daemon.sh >/dev/null 2>&1 &```
4. Display unread mail in terminal: Add this to the end of your ```~/.bashrc``` or ```~/.zshrc```: <br> 
```bash
if [[ -f "$HOME/.cache/smtn/mail" ]]; then 
  echo "📬 Unread mail: $(<"$HOME/.cache/smtn/mail")"
fi
```

## 🧩 Configuration
The first time you run the script, a config file will be created at:``` ~/.config/smtn/config ```. <br>
Edit it to add your mailboxes. Example: <br>
```text
# Refresh interval in seconds (default: 600 = 10 minutes)
MAILBOX_REFRESH_RATE=600

# Gmail
SMTN_GMAIL_IMAP="imap.gmail.com:993"
SMTN_GMAIL_LOGIN="your@gmail.com"
SMTN_GMAIL_APP_PASSWORD="your_app_password"

# Outlook
SMTN_OUTLOOK_IMAP="imap-mail.outlook.com:993"
SMTN_OUTLOOK_LOGIN="your@outlook.com"
SMTN_OUTLOOK_APP_PASSWORD="your_app_password"

# Add as many accounts as you want using the same structure.
```

## 🔄 How It Works
* The daemon (```smtn-daemon.sh```) runs continuously in the background.
* Every ```MAILBOX_REFRESH_RATE``` seconds, it connects to each IMAP server and issues: <br>
```STATUS INBOX (UNSEEN)``` <br>
* It extracts the unread mail count and writes it to: <br>
```~/.cache/smtn/mail```
* Your shell reads and displays this value on terminal startup.

## 📤 Supported IMAP Servers
You can use **SMTN** with:
* Gmail
* Yahoo Mail
* Outlook / Hotmail
* Yandex
* iCloud
* GMX
* Mail.ru
* ProtonMail (with Proton Bridge)
* And many more.

## ✅ License
MIT — do whatever you want.
