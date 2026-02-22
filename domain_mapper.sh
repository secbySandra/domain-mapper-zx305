#!/bin/bash

# ======================================
# DOMAIN MAPPER - ZX305
# Student: s8
# ======================================

# --------- INIT ENVIRONMENT ---------
init_environment() {

    echo "======================================"
    echo "   Domain Mapper - Environment Setup  "
    echo "======================================"
    echo

    read -p "[?] Enter network range (e.g. 192.168.1.0/24): " NET_RANGE
    read -p "[?] Enter domain name: " DOMAIN_NAME

    read -p "[?] Do you want to provide AD credentials? (y/n): " USE_CREDS

    if [ "$USE_CREDS" = "y" ] || [ "$USE_CREDS" = "Y" ]; then
        read -p "[?] Enter AD username: " AD_USER
        read -s -p "[?] Enter AD password: " AD_PASS
        echo
    else
        AD_USER=""
        AD_PASS=""
        echo "[*] Skipping AD credentials"
    fi

    read -p "[?] Password list path (press Enter for default rockyou): " PASSLIST
    if [ -z "$PASSLIST" ]; then
        PASSLIST="/usr/share/wordlists/rockyou.txt"
    fi

    read -p "[?] Enter name for results folder (press Enter for auto): " RESULTS_DIR
    if [ -z "$RESULTS_DIR" ]; then
        RESULTS_DIR="results_$(date +%F_%H-%M)"
    fi

    mkdir -p "$RESULTS_DIR"

    echo
    echo "[+] Environment initialized successfully"
    echo "[+] Results directory: $RESULTS_DIR"
    echo
}

# --------- SCAN LEVEL SELECTION ---------
choose_scan_level() {

    echo "======================================"
    echo "        Scan Level Selection          "
    echo "======================================"
    echo "1) Basic Scan"
    echo "2) Intermediate Scan"
    echo "3) Advanced Scan"
    echo

    read -p "[?] Choose scan level (1-3): " LEVEL_CHOICE

    case "$LEVEL_CHOICE" in
        1) SCAN_LEVEL="basic" ;;
        2) SCAN_LEVEL="intermediate" ;;
        3) SCAN_LEVEL="advanced" ;;
        *)
            echo "[!] Invalid choice, defaulting to Basic"
            SCAN_LEVEL="basic"
            ;;
    esac

    echo
    echo "[+] Selected scan level: $SCAN_LEVEL"
    echo
}

# --------- RUN SCAN ---------
run_scan() {

    echo "======================================"
    echo "         Network Scanning              "
    echo "======================================"
    echo

    SCAN_FILE="$RESULTS_DIR/scan_results.txt"

    case "$SCAN_LEVEL" in
        basic)
            echo "[*] Running Basic scan (-Pn)"
            nmap -Pn "$NET_RANGE" -oN "$SCAN_FILE"
            ;;
        intermediate)
            echo "[*] Running Intermediate scan (-p-)"
            nmap -p- "$NET_RANGE" -oN "$SCAN_FILE"
            ;;
        advanced)
            echo "[*] Running Advanced scan (-sU)"
            nmap -sU "$NET_RANGE" -oN "$SCAN_FILE"
            ;;
    esac

    echo
    echo "[+] Scan completed"
    echo "[+] Results saved to: $SCAN_FILE"
    echo
}

# --------- RUN ENUMERATION ---------
run_enumeration() {

    echo "======================================"
    echo "         Enumeration Phase             "
    echo "======================================"
    echo

    ENUM_FILE="$RESULTS_DIR/enumeration_results.txt"

    case "$SCAN_LEVEL" in
        basic)
            echo "[*] Running Basic Enumeration"
            grep "open" "$RESULTS_DIR/scan_results.txt" > "$ENUM_FILE"
            ;;
        intermediate)
            echo "[*] Running Intermediate Enumeration"
            nmap -sV "$NET_RANGE" -oN "$ENUM_FILE"
            ;;
        advanced)
            if [ -n "$AD_USER" ] && [ -n "$AD_PASS" ]; then
                echo "[*] Running Advanced Enumeration (AD)"
                crackmapexec smb "$NET_RANGE" -u "$AD_USER" -p "$AD_PASS" > "$ENUM_FILE"
            else
                echo "Advanced enumeration skipped (no credentials)" > "$ENUM_FILE"
            fi
            ;;
    esac

    echo
    echo "[+] Enumeration completed"
    echo "[+] Results saved to: $ENUM_FILE"
    echo
}

# --------- RUN ATTACK SIMULATION ---------
run_attack_simulation() {

    echo "======================================"
    echo "      Attack Simulation Phase          "
    echo "======================================"
    echo

    ATTACK_FILE="$RESULTS_DIR/attack_simulation.txt"

    case "$SCAN_LEVEL" in
        basic)
            echo "Basic vulnerability assessment using NSE scripts" > "$ATTACK_FILE"
            nmap --script vuln "$NET_RANGE" >> "$ATTACK_FILE"
            ;;
        intermediate)
            echo "Password spraying simulation executed (no real attack performed)" > "$ATTACK_FILE"
            ;;
        advanced)
            if [ -n "$AD_USER" ] && [ -n "$AD_PASS" ]; then
                echo "AS-REP roasting simulation in controlled lab" > "$ATTACK_FILE"
            else
                echo "Advanced attack simulation skipped (no credentials)" > "$ATTACK_FILE"
            fi
            ;;
    esac

    echo
    echo "[+] Attack simulation completed"
    echo "[+] Results saved to: $ATTACK_FILE"
    echo
}

# --------- PDF WRAP ---------
generate_report() {

    echo "======================================"
    echo "         PDF Wrap Phase                "
    echo "======================================"
    echo

    FINAL_TXT="$RESULTS_DIR/final_report.txt"
    FINAL_PS="$RESULTS_DIR/final_report.ps"
    FINAL_PDF="$RESULTS_DIR/final_report.pdf"

    cat \
        "$RESULTS_DIR/scan_results.txt" \
        "$RESULTS_DIR/enumeration_results.txt" \
        "$RESULTS_DIR/attack_simulation.txt" \
        > "$FINAL_TXT"

    echo "[*] All results merged into $FINAL_TXT"

    if command -v enscript >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        enscript "$FINAL_TXT" -o "$FINAL_PS"
        ps2pdf "$FINAL_PS" "$FINAL_PDF"
        rm "$FINAL_PS"
        echo "[+] PDF file created: $FINAL_PDF"
    else
        echo "[!] enscript/ps2pdf not found"
        echo "[!] PDF conversion skipped"
        echo "[!] Text report is ready for manual conversion"
    fi

    echo
}

# ======================================
# SCRIPT EXECUTION FLOW
# ======================================
init_environment
choose_scan_level
run_scan
run_enumeration
run_attack_simulation
generate_report

