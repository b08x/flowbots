import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=1000,
    temperature=0.3,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "How would you add an additional keyboard layout in Arch Linux using... ugh, shoot. Because it needs the map like special keys. Ah, shit. Or shoot, I mean shoot."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "To add an additional keyboard layout in Arch Linux, you can follow these steps:\n\n1. Install the necessary packages:\n   ```\n   sudo pacman -S xorg-setxkbmap\n   ```\n\n2. Identify the keyboard layout you want to add. You can find the available layouts in the `/usr/share/X11/xkb/symbols/` directory. For example, if you want to add the German keyboard layout, look for the file named `de`.\n\n3. Create or edit the `~/.Xmodmap` file in your home directory. If it doesn't exist, create it using a text editor.\n\n4. Open the `~/.Xmodmap` file and add the following line to specify the additional keyboard layout:\n   ```\n   xkbmap -layout us,de\n   ```\n   Replace `us` and `de` with the desired keyboard layouts you want to use. In this example, it sets the primary layout to US and the secondary layout to German.\n\n5. Save the `~/.Xmodmap` file.\n\n6. To apply the changes, run the following command:\n   ```\n   xmodmap ~/.Xmodmap\n   ```\n\n7. If you want the keyboard layout to be set automatically when you log in, you can add the `xmodmap` command to your X session startup file. For example, if you're using the LightDM display manager, you can add the following line to the `~/.xprofile` file:\n   ```\n   xmodmap ~/.Xmodmap\n   ```\n\n8. Log out and log back in, or restart your X session for the changes to take effect.\n\nAfter following these steps, you should be able to switch between the primary and secondary keyboard layouts using the default key combination (usually `Alt+Shift` or `Super+Space`).\n\nIf you need to map special keys or customize the keyboard layout further, you can modify the `~/.Xmodmap` file accordingly. You can refer to the `xmodmap` manual page (`man xmodmap`) for more information on the syntax and available options."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please describe the symbols and their functions as depicted in this illusion:\n"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": "<base64_encoded_image>"
                    }
                }
            ]
        }
    ]
)
print(message.content)
