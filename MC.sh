#!/bin/bash

# Predefined list of models
models=(
    "openai"
    "openai-large"
    "openai-reasoning"
    "qwen-coder"
    "llama"
    "mistral"
    "roblox-rp"
    "unity"
    "midijourney"
    "rtist"
    "searchgpt"
    "evil"
    "deepseek"
    "deepseek-r1"
    "qwen-reasoning"
    "llamalight"
    "phi"
    "llama-vision"
    "pixtral"
    "gemini"
    "gemini-thinking"
    "hypnosis-tracy"
)

while true; do
    echo "Available Models:"
    echo "-----------------"
    for i in "${!models[@]}"; do
        echo "$((i+1))) ${models[i]}"
    done

    # Prompt user for model selection
    echo ""
    read -p "Enter the number of the model you want to use (or type 'exit' to quit): " choice

    # Exit option
    if [[ "$choice" == "exit" ]]; then
        echo "Exiting..."
        exit 0
    fi

    # Validate selection
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#models[@]})); then
        echo "Invalid selection. Please try again."
        continue
    fi

    selected_model="${models[$((choice-1))]}"
    echo "You selected: $selected_model"

    # Keep asking questions until user quits
    while true; do
        echo ""
        read -p "Enter your question for the AI (or type 'q' to choose another model): " user_prompt

        # Return to model selection menu
        if [[ "$user_prompt" == "q" ]]; then
            echo "Returning to model selection..."
            break
        fi

        # Make a POST request using the selected model and user's question
        response=$(curl -s -X POST "https://text.pollinations.ai" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$selected_model\", \"messages\": [{\"role\": \"user\", \"content\": \"$user_prompt\"}]}" )

        # Check if response is empty or invalid
        if [[ -z "$response" ]]; then
            echo "Error: No response from AI."
            continue
        fi

        # Extract plain text response using jq
        plain_text=$(echo "$response" | jq -r '.messages[0].content' 2>/dev/null)

        # If jq parsing fails, show raw response
        if [[ "$plain_text" == "null" || -z "$plain_text" ]]; then
            echo "Error parsing response. Raw output:"
            echo "$response"
        else
            # Display the AI's response
            echo ""
            echo "AI Response:"
            echo "------------"
            echo "$plain_text"
            echo "------------"
        fi
    done
done
