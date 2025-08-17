#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domains_file>"
    exit 1
fi

DOMAINS_FILE="$1"

# Check if file exists
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Error: File '$DOMAINS_FILE' not found!"
    exit 1
fi

# Create subs directory if it doesn't exist
mkdir -p subs

# Run Assetfinder
echo "[+] Running Assetfinder..."
cat "$DOMAINS_FILE" | assetfinder --subs-only > subs/af.txt

# Run Subfinder
echo "[+] Running Subfinder..."
subfinder -dL "$DOMAINS_FILE" -all -o subs/sf.txt

# Run Amass
echo "[+] Running Amass..."
amass enum -passive -df "$DOMAINS_FILE" -o subs/am.txt

# Run Shosubgo
echo "[+] Running Shosubgo..."
# <-- change the Shodan API key below if needed -->
shosubgo -f "$DOMAINS_FILE" -s api-key | tee -a subs/shosub.txt

# Run Findomain and split output
echo "[+] Running Findomain..."
findomain -f "$DOMAINS_FILE" -i | tee subs/findo_raw.txt \
    | awk -F',' '{print $1 > "subs/findo.txt"; print $2 > "subs/findo_ip.txt"}'

echo "[+] All results saved in 'subs/' directory."
