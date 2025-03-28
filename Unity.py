import requests
import json

# Set the AI model to Unity
selected_model = "unity"
                                                      # ANSI color codes
blue = '\033[1;34m'
green = '\033[1;32m'                                  reset = '\033[0m'
                                                      # Get a custom system prompt (instructional prompt)
default_prompt = "You are a helpful assistant."       system_prompt = input(f"Enter a system prompt for the chatbot (or press enter for default: \"{default_prompt}\"): ").strip()
if not system_prompt:
    system_prompt = default_prompt

# Initialize conversation history as a list of messages with a system prompt
history = [{"role": "system", "content": system_prompt}]

print("\nChat with Unity or type 'e' to exit\n")

while True:
    print("")
    user_prompt = input("_> ")

    # Exit option
    if user_prompt.strip().lower() == "e":
        print("\nExiting the chat. Goodbye!")
        break

    # Display your input in blue
    print(f"\n{blue}KB: {user_prompt}{reset}\n")

    # Append user's message to the conversation history
    history.append({"role": "user", "content": user_prompt})

    # DEBUG: Print the full conversation history before sending
    print("DEBUG: Conversation history to be sent:")
    print(json.dumps(history, indent=2))
    print("--------------------------------------------------\n")

    # Make a POST request with the conversation history and max_tokens set to 4096
    try:
        response = requests.post(
            "https://text.pollinations.ai",
            headers={"Content-Type": "application/json"},
            json={"model": selected_model, "messages": history, "max_tokens": 4096}
        )

        try:
            data = response.json()
        except json.JSONDecodeError:
            data = None

        if not data:
            ai_response = response.text.strip() if response.text else "[No response or error occurred]"
        else:
            # Try extracting the assistant's response from the returned JSON
            if "messages" in data and isinstance(data["messages"], list) and len(data["messages"]) > 0:
                ai_response = data["messages"][-1]["content"]
            else:
                ai_response = response.text.strip()
    except Exception as e:
        ai_response = f"[An error occurred: {e}]"

    # Append the AI's response to the conversation history
    history.append({"role": "assistant", "content": ai_response})

    # Display AI's response in green
    print(f"{green}AI: {ai_response}{reset}\n")
