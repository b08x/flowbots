#!/usr/bin/env python
import json
import argparse
import os
import subprocess
import re


def parse_chat(file_path, output_file):
    """Parses a Claude chat file and writes sender and text of each message to a markdown file."""
    with open(file_path, "r") as f:
        data = json.load(f)

    with open(output_file, "w") as outfile:
        for message in data["chat_messages"]:
            sender = message["sender"]
            text = message["text"]

            # Remove empty code blocks from text
            text = re.sub(r"```\s*```", "", text)

            # Check for attachments and extracted content
            if (
                "attachments" in message
                and message["attachments"]
                and "extracted_content" in message["attachments"][0]
            ):
                extracted_content = message["attachments"][0]["extracted_content"]
                if extracted_content.strip():  # Check if extracted_content is not empty
                    text += "\n\n```\n" + extracted_content + "\n```"

            if sender == "human":
                outfile.write(f"## Human:\n\n{text}\n\n")  # Add extra newline for spacing
            elif sender == "assistant":
                outfile.write(
                    f"### Assistant:\n\n{text}\n\n---\n\n"
                )  # Add extra newline for spacing


def process_input(input_path, output_dir):
    """Processes either a single file or a folder of chat files."""
    if os.path.isfile(input_path):
        # Single file
        if input_path.endswith(".json"):
            filename = os.path.basename(input_path)[:-5]  # Remove .json extension
            output_file = os.path.join(output_dir, filename + ".md")
            parse_chat(input_path, output_file)
        else:
            print(f"Error: Invalid file format. Please provide a JSON file.")
    elif os.path.isdir(input_path):
        # Folder
        for filename in os.listdir(input_path):
            if filename.endswith(".json"):
                file_path = os.path.join(input_path, filename)
                output_file = os.path.join(output_dir, filename[:-5] + ".md")
                parse_chat(file_path, output_file)
    else:
        print(f"Error: Invalid input path. Please provide a valid file or folder.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Parse Claude chat files and output to markdown."
    )
    parser.add_argument(
        "input_path", help="Path to a chat JSON file or a folder containing JSON files."
    )
    args = parser.parse_args()

    try:
        process = subprocess.run(
            ["yad", "--file", "--directory"], capture_output=True, text=True
        )
        output_dir = process.stdout.strip()
        if not output_dir:
            print("No directory selected.")
        else:
            process_input(args.input_path, output_dir)
    except subprocess.CalledProcessError as e:
        print(f"Error running yad: {e}")
