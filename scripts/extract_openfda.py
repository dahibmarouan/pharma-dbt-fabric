import os
import time
import json
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENFDA_API_KEY")
BASE_URL = "https://api.fda.gov/drug/event.json"
PAGE_SIZE = 100
MAX_RECORDS = 500
OUTPUT_DIR = Path("data/raw")


def fetch_page(skip: int, limit: int) -> dict:
    params = {"api_key": API_KEY, "limit": limit, "skip": skip}
    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()
    return response.json()


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    skip, page_number = 0, 0

    while skip < MAX_RECORDS:
        data = fetch_page(skip=skip, limit=PAGE_SIZE)
        results = data.get("results", [])
        if not results:
            print("Plus de résultats disponibles, arrêt.")
            break

        output_file = OUTPUT_DIR / f"page_{page_number:03d}.json"
        output_file.write_text(json.dumps(results, indent=2))
        print(f"Page {page_number} : {len(results)} rapports sauvegardés dans {output_file}")

        skip += PAGE_SIZE
        page_number += 1
        time.sleep(0.5)


if __name__ == "__main__":
    main()