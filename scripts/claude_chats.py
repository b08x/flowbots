import dotenv
import os
import json
import time  # Import the time module
from datetime import datetime
import argparse  # Import the argparse module


# The ClaudeClient is the raw API that gives you access to all organization and conversation level API calls
# with a simple python interface. However, you have to pass organization_uuid and conversation_uuid everywhere, so
# its not ideal if you want a simple to use API.
from claude import claude_client

# The ClaudeWrapper takes in a claude client instance and allows you to use a single organization and conversation
# context. This allows you to use the API more ergonomically.
from claude import claude_wrapper

dotenv.load_dotenv()

session_key = os.getenv("SESSION_KEY")

client = claude_client.ClaudeClient(session_key)

print(session_key)

organizations = client.get_organizations()
claude_obj = claude_wrapper.ClaudeWrapper(
    client, organization_uuid=organizations[0]["uuid"]
)

# projects = claude_obj.get_projects()
# print(dir(api_url))

# print(api_url)

# Create an argument parser
parser = argparse.ArgumentParser(description="Download Claude chat history.")
parser.add_argument("--conversation_id", help="Conversation ID to download (optional)")

# Parse the arguments
args = parser.parse_args()

conversations = claude_obj.get_conversations()

if args.conversation_id:
    # Download a single conversation
    conversation = next(
        (c for c in conversations if c["uuid"] == args.conversation_id), None
    )
    if conversation:
        conversation_id = conversation["uuid"]
        updated_at = conversation["updated_at"]
        name = conversation["name"]
        if not name:
            name = "no name"

        dt_obj = datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%S.%f%z")
        formatted_date = dt_obj.strftime(
            "%Y-%m-%d-%I:%M%p"
        ).lower()  # Lowercase for typical file names

        filename = f"{formatted_date}-{name.replace('/', '-')}-{conversation_id}.json"
        filename = filename.replace(
            ":", "_"
        )  # Replace colons (':') with underscores ('_') for compatibility
        filename = filename.replace(
            " ", "_"
        )  # Replace colons (':') with underscores ('_') for compatibility

        history = claude_obj.get_conversation_info(conversation_id)

        json_object = json.dumps(history)

        print(filename)
        os.makedirs("claude_chatsC", exist_ok=True)

        try:
            with open(f"claude_chatsC/{filename}", "w") as outfile:
                outfile.write(json_object)
        except Exception as e:
            print(f"Error writing to file: {e}")

        print("chat dump complete")
    else:
        print(f"Conversation with ID {args.conversation_id} not found.")
else:
    # Download all conversations (as before)
    for conversation in conversations:
        conversation_id = conversation["uuid"]
        updated_at = conversation["updated_at"]
        name = conversation["name"]
        print(conversation_id)
        if not name:
            name = "no name"

        dt_obj = datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%S.%f%z")
        formatted_date = dt_obj.strftime(
            "%Y-%m-%d-%I:%M%p"
        ).lower()  # Lowercase for typical file names

        filename = f"{formatted_date}-{name}.json"  # Example: .txt extension
        filename = filename.replace(
            ":", "_"
        )  # Replace colons (':') with underscores ('_') for compatibility
        filename = filename.replace(
            " ", "_"
        )  # Replace colons (':') with underscores ('_') for compatibility

        history = claude_obj.get_conversation_info(conversation_id)

        json_object = json.dumps(history)

        print(filename)
        os.makedirs("claude_chatsC", exist_ok=True)

        try:
            with open(f"claude_chatsC/{filename}", "w") as outfile:
                outfile.write(json_object)
        except Exception as e:
            print(f"Error writing to file: {e}")
        time.sleep(5)

        print("chat dump complete")
