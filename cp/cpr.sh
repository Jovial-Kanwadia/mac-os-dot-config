#!/usr/bin/env bash

# --- Configuration ---
# Hardened Clang flags for CP
# -O2: Optimization level used by most judges
# -fsanitize: Catches array out-of-bounds and undefined behavior
CFLAGS="-std=c++20 -O2 -Wall -Wextra -Wshadow -DLOCAL \
        -fsanitize=address,undefined -fno-omit-frame-pointer"
SOURCE="sol.cpp"
BINARY="sol.out"
INPUT="in.txt"
OUTPUT="out.txt"
ANS="ans.txt"
HEADER_PATH="$HOME/.config/cp/include"
BLUE='\033[0;34m'

# Build Modes: Toggle with 'cpr' (Debug) or 'cpr -r' (Release)
if [[ "$1" == "-r" ]]; then
    # Release Mode: Fast, no sanitizers
    CFLAGS="-std=c++20 -O2 -I$HEADER_PATH"
    MODE="RELEASE"
else
    # Debug Mode: Sanitizers to catch bugs
    CFLAGS="-std=c++20 -Wall -Wextra -Wshadow -fsanitize=address,undefined -g -I$HEADER_PATH"
    MODE="DEBUG"
fi

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Compilation
echo -e "${BLUE}● Compiling in $MODE mode...${NC}"
if ! clang++ $CFLAGS "$SOURCE" -o "$BINARY"; then
    echo -e "${RED}✗ Compilation Failed${NC}"
    exit 1
fi

# 2. Execution Monitoring (TLE and Memory)
# gtimeout 2s: Kills if it takes > 2 seconds
# /usr/bin/time -l: (macOS specific) reports peak memory usage
echo -e "${BLUE}┌── Validating Execution ─────────────────────────────────┐${NC}"

if gtimeout 2s /usr/bin/time -l ./"$BINARY" < "$INPUT" > "$OUTPUT" 2> .stats; then
    # Parse stats
    TIME=$(grep "real" .stats | awk '{print $1}')
    MEM_BYTES=$(grep "maximum resident set size" .stats | awk '{print $1}')
    MEM_MB=$(echo "scale=2; $MEM_BYTES / 1024 / 1024" | bc)
    
    # Check Verdict
    VERDICT="${GREEN}PASS${NC}"
    if [[ -f "$ANS" ]]; then
        if ! diff -w "$OUTPUT" "$ANS" > /dev/null; then
            VERDICT="${RED}FAIL${NC}"
        fi
    fi

    # Display Dashboard
    echo -e "${BLUE}│${NC} Verdict: $VERDICT"
    echo -e "${BLUE}│${NC} Time:    ${TIME}s"
    echo -e "${BLUE}│${NC} Memory:  ${MEM_MB}MB"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"

    # Show Output
    echo -e "\n${BLUE}Output:${NC}"
    cat "$OUTPUT"

    # Show Diff if Fail
    if [[ "$VERDICT" == *FAIL* ]]; then
        echo -e "\n${RED}Diff (Yours vs. Expected):${NC}"
        diff -w -y --suppress-common-lines "$OUTPUT" "$ANS"
    else
        echo -e "\n${BLUE}Output:${NC}"
        cat "$OUTPUT"
        cat "$OUTPUT" | pbcopy
    fi
else  
    EXIT_CODE=$?
    echo -e "${BLUE}│${NC} Verdict: ${RED}ERROR${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
    # Check if it was a TLE or a Crash
    if [[ $? -eq 124 ]]; then
        echo -e "${RED}❌ TLE (Time Limit Exceeded > 2s)${NC}"
    else
        echo -e "${RED}❌ RUNTIME ERROR (Check Sanitizers)${NC}"
        cat .stats | grep "AddressSanitizer"
    fi
fi

rm -f .stats
