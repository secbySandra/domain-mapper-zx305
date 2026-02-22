# Domain Mapper – Automated Network Assessment (ZX305)

## Overview

Domain Mapper is a Bash-based automated network security assessment tool developed in a Kali Linux lab environment.

The script simulates structured phases of a penetration testing workflow while maintaining a safe and controlled execution model.

This project focuses on automation, structured reporting, and educational attack simulation.

---

## Features

- Multi-level scan selection (Basic / Intermediate / Advanced)
- Automated Nmap scanning
- Enumeration phase based on scan results
- Controlled attack simulation (no uncontrolled exploitation)
- Structured output directory generation
- Automated report merging
- Optional PDF report generation

---

## Technical Stack

- Bash
- Nmap
- CrackMapExec (for AD simulation)
- Enscript / ps2pdf (optional report generation)
- Kali Linux

---

## Workflow

1. Environment initialization (network range, domain, optional AD credentials)
2. Scan level selection
3. Network scanning
4. Enumeration phase
5. Attack simulation (educational purpose only)
6. Final report generation

---

## Disclaimer

All testing was conducted in a controlled lab environment for educational purposes only.
No real-world systems were targeted.
## How to Run

chmod +x domain_mapper.sh
./domain_mapper.sh
