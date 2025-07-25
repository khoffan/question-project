import argparse
import json
import os
from deep_translator import GoogleTranslator

parser = argparse.ArgumentParser(description="Translate JSON files in a folder to multiple languages")

parser.add_argument("-s", "--source_folder", type=str, default="en", help="Source language folder path")
parser.add_argument("-t", "--target_folders", type=str, nargs='+', help="Target language folder paths")
parser.add_argument("-l", "--target_langs", type=str, nargs='+', help="Target language codes")

args = parser.parse_args()

def translate_text(text, target_lang="th"):
    placeholder = []
    while "{}" in text:
        placeholder.append("{}")
        text = text.replace("{}", "123", 1)

    translated_text = GoogleTranslator(source='en', target=target_lang).translate(text)

    for place in placeholder:
        translated_text = translated_text.replace("123", place, 1)

    return translated_text

def translate_json(data, target_lang="th"):
    if isinstance(data, dict):
        return {key: translate_json(value, target_lang) for key, value in data.items()}
    elif isinstance(data, list):
        return [translate_json(value, target_lang) for value in data]
    elif isinstance(data, str):
        return translate_text(data, target_lang)
    return data

def main():
    source_folder = args.source_folder
    target_langs = args.target_langs
    target_folders = args.target_folders

    if len(target_langs) != len(target_folders):
        raise ValueError("Number of target languages and folders must match")

    for lang, folder in zip(target_langs, target_folders):
        print(f"\n--- Processing language: {lang.upper()} ---")
        os.makedirs(folder, exist_ok=True)

        for filename in os.listdir(source_folder):
            if filename.endswith(".json"):
                source_path = os.path.join(source_folder, filename)
                target_path = os.path.join(folder, filename)

                with open(source_path, "r", encoding="utf-8") as f:
                    data = json.load(f)

                translated_data = translate_json(data, lang)

                with open(target_path, "w", encoding="utf-8") as f:
                    json.dump(translated_data, f, ensure_ascii=False, indent=4)

                print(f"[{lang.upper()}] Translated {filename} → {target_path}")

if __name__ == "__main__":
    main()
