#!/bin/bash

HISTORY_FILE="${1}"
OLLAMA_HOST="http://localhost:11434"
OLLAMA_MODEL="codellama:13b"
TMP_FOLDER="${HOME}/.cache/vim/ollama"
CTX_FILE="${TMP_FOLDER}/${HISTORY_FILE//\//-}.context"
mkdir -p "${TMP_FOLDER}"
USER_SEPARATOR=">>> user >>>"
ASSISTANT_SEPARATOR="<<< assistant <<<"
FILE_INJECTION_PATTERN="(.*)\{\{(.*)\}\}(.*)"

process_line() {
    while read -r line; do
        isdone="$(echo "$line" | jq -r '.done')"
        if [ "${isdone}" = "true" ]; then
            echo "$line" | jq -r '.context' >"${CTX_FILE}"
        fi
        echo "$line" | jq -j '.response' >>"${HISTORY_FILE}"
    done
}

ollama_generate() {
    prompt="$1"
    if [ -f "${CTX_FILE}" ]; then
        body="{\"model\":\"${OLLAMA_MODEL}\", \"prompt\": \"${prompt}\", \"stream\": true, \"context\": $(cat "${CTX_FILE}")}"
    else
        echo "No context file found for ${HISTORY_FILE}, starting new conversation"
        body="{\"model\":\"${OLLAMA_MODEL}\", \"prompt\": \"${prompt}\", \"stream\": true}"
    fi
    echo "${body}" >/tmp/body.json
    echo -ne "\n\n${ASSISTANT_SEPARATOR}\n" >>"${HISTORY_FILE}"
    curl -s -X POST "${OLLAMA_HOST}/api/generate" \
        -H "Content-Type: application/json" \
        -d "${body}" | process_line
    # shellcheck disable=SC2181
    if [ $? != 0 ]; then
        echo "Failed to generate response"
        exit 1
    fi
    echo "" >>"${HISTORY_FILE}"
}

get_last_user_prompt() {
    backwards_file=$(sed '1!G;h;$!d' "${HISTORY_FILE}")
    txt=""
    echo -ne "${backwards_file}\n" | while read -r line; do
        if [ "${line}" = "${USER_SEPARATOR}" ]; then
            # shellcheck disable=SC2028
            echo "${txt}"
            return
        elif [ "${line}" = "${ASSISTANT_SEPARATOR}" ]; then
            echo ""
            return
        else
            txt="${line}\n${txt}"
        fi
    done
}

inject_files() {
    chat_home=$(dirname "${HISTORY_FILE}")
    cd "$chat_home" || exit 1
    echo -ne "${1}\n" | while read -r line; do
        if [[ "${line}" =~ ${FILE_INJECTION_PATTERN} ]]; then
            file_path="${BASH_REMATCH[2]}"
            file_content="$(sed 's/$/\\n/g' "${file_path}" | tr -d '\n')"
            file_content="$(echo "${file_content}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
            # shellcheck disable=SC2028
            echo "${BASH_REMATCH[1]}${file_content}${BASH_REMATCH[3]}\n" | sed 's/$/\\n/g' | tr -d '\n'
        else
            # shellcheck disable=SC2028
            echo "${line}\n" | sed 's/$/\\n/g; s/"/\\"/g' | tr -d '\n'
        fi
    done
    cd - || exit 1
}

echo "Analyzing chat from file ${HISTORY_FILE}"
PROMPT=$(get_last_user_prompt)
echo "Prompt: ${PROMPT}"
if [ "${PROMPT}" != "" ]; then
    PROMPT=$(inject_files "${PROMPT}")
    echo "Calling LLM and posting response to file ${HISTORY_FILE}"
    ollama_generate "${PROMPT}"
else
    echo "No prompt found"
fi
echo "Done"
