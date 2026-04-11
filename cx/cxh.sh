#!/usr/bin/env bash

# --- Configuration ---
LANGS="cpp python go rust javascript lua"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

MODEL="gemini-2.5-flash"

# 1. Select Language via fzf
LANG=$(echo $LANGS | tr ' ' '\n' | fzf --prompt="Language> " --height=40% --reverse)
[ -z "$LANG" ] && exit 0

# 2. Select Search Mode
MODE=$(echo -e "Community Cheatsheet (cht.sh)\nAI (Gemini)" | fzf --prompt="Mode> " --height=40% --reverse)
[ -z "$MODE" ] && exit 0

read -p "Query: " QUERY
[ -z "$QUERY" ] && exit 0

# Replace spaces with plus for URL safety
ENCODED_QUERY=$(echo "$QUERY" | tr ' ' '+')

if [[ "$MODE" == *"cht.sh"* ]]; then
    echo -e "${BLUE}● Fetching $LANG/$QUERY from cht.sh...${NC}\n"
    curl -s "cht.sh/$LANG/$ENCODED_QUERY" | less -R
else
    # --- Gemini Integration ---
    API_KEY_FILE="$HOME/.config/gemini_api_key"
    if [[ ! -f "$API_KEY_FILE" ]]; then
        echo -e "${RED}❌ API Key not found in $API_KEY_FILE${NC}"
        exit 1
    fi
    GEMINI_API_KEY=$(cat "$API_KEY_FILE")

    echo -e "${CYAN}● AI (Gemini)...${NC}\n"

    # THE SYSTEM PROMPT: Hardware-level focus
    SYSTEM_MSG="You are a hardware-aware technical data stream. 
    Rules:
    1. NO MARKDOWN (no backticks, hashes, or asterisks).
    2. NO CONVERSATIONAL FILLER. No 'Certainly', 'Here is', or 'Note'.
    3. Be extremely detailed about memory layout (stack vs heap), pointer arithmetic, and cache alignment.
    4. Use ALL CAPS for headers.
    5. Code must be naked with output as a comment."

    # THE USER PROMPT: Complex Detail Request
    USER_MSG="Deep-dive technical specification for '$QUERY' in $LANG.
    STRUCTURE:
    INTERNAL MECHANICS: (Byte-level detail, memory layout, stack/heap behavior)
    PERFORMANCE: (Cache impact, alignment requirements, Big O complexity)
    CODE IMPLEMENTATION: (Naked code + expected output in comments)"

    # Build Payload for Gemini 2.0 Flash
    # Note: Using system_instruction for the hard-coded persona
    PAYLOAD=$(jq -n \
        --arg system "$SYSTEM_MSG" \
        --arg prompt "$USER_MSG" \
        '{
            system_instruction: { parts: { text: $system } },
            contents: { parts: { text: $prompt } },
            generationConfig: {
                temperature: 0.1,
                maxOutputTokens: 8192,
                topP: 0.1
            }
        }')

    URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}"
    
    RESPONSE_JSON=$(curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$URL")
    RESPONSE=$(echo "$RESPONSE_JSON" | jq -r '.candidates[0].content.parts[0].text // empty')

    if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
        echo -e "${RED}❌ Error: Gemini response empty or API key invalid.${NC}"
        echo "Raw response for debug: $RESPONSE_JSON"
    else
        # STRIP MARKDOWN ARTIFACTS: Final safety filter
        CLEAN_RESPONSE=$(echo "$RESPONSE" | sed -E 's/\*\*//g; s/`//g; s/^[#*]+ //')        

        # Display in less (-X keeps content on screen after exit)
        echo -e "$CLEAN_RESPONSE" | less -R -X
    fi
fi
