#!/bin/bash

AUTHORIZED_USERS_FILE="authorized_users.txt"

echo "=========================================="
echo "     CyberPatriot User & Update Script"
echo "=========================================="

# -----------------------------
# SYSTEM UPDATE
# -----------------------------
echo "[+] Updating system..."
apt update && apt upgrade -y


# -----------------------------
# CHECK AUTHORIZED USERS
# -----------------------------
if [ ! -f "$AUTHORIZED_USERS_FILE" ]; then
    echo "[-] ERROR: authorized_users.txt is missing."
    echo "Create it and list ALLOWED usernames:"
    echo "root"
    echo "student"
    echo "team1"
    echo
    exit 1
fi

echo "[+] Authorized users:"
cat "$AUTHORIZED_USERS_FILE"
echo

echo "[+] Scanning system users..."
ALL_USERS=$(cut -d: -f1 /etc/passwd)

for user in $ALL_USERS; do
    if ! grep -Fxq "$user" "$AUTHORIZED_USERS_FILE"; then
        echo "[-] Unauthorized user detected: $user"
        
        # Lock user
        passwd -l "$user" 2>/dev/null
        
        # Delete user and home directory
        userdel -r "$user" 2>/dev/null
        
        echo "  -> Removed user: $user"
    fi
done


# -----------------------------
# DOUBLE CHECK FOR UID 0 ACCOUNTS
# -----------------------------
echo
echo "[+] Checking for unauthorized UID 0 accounts..."
awk -F: '($3 == 0 && $1 != "root") {print "!! Unauthorized root user: " $1}' /etc/passwd


# -----------------------------
# VERIFY SUDO GROUP
# -----------------------------
echo
echo "[+] Checking sudo group members..."
grep "^sudo" /etc/group


# -----------------------------
# DONE
# -----------------------------
echo
echo "=========================================="
echo "   User Hardening & Update Completed"
echo "=========================================="
