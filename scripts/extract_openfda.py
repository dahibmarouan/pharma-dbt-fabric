import os
import time
import json
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENFDA_API_KEY")
BASE_URL = "https://api.fda.gov/drug/event.json"
PAGE_SIZE = 1000
MAX_RECORDS = 20000
OUTPUT_DIR = Path("data/raw")


def fetch_page(skip: int, limit: int) -> dict:
    """Fetch a 'page' of results from the openFDA API."""
    params = {
        "api_key": API_KEY,
        "limit": limit,
        "skip": skip,
        "sort": "receivedate:asc",
    }
    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()
    return response.json()


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    skip, page_number = 0, 0
    seen_ids = set()

    while skip < MAX_RECORDS:
        data = fetch_page(skip=skip, limit=PAGE_SIZE)
        results = data.get("results", [])
        if not results:
            print("No more results available, stopping.")
            break

        # Defensive deduplication: skip/limit can return the same report
        # on two pages when several reports share the same sort date.
        new_results = []
        for r in results:
            rid = r.get("safetyreportid")
            if rid not in seen_ids:
                seen_ids.add(rid)
                new_results.append(r)

        output_file = OUTPUT_DIR / f"page_{page_number:03d}.json"
        output_file.write_text(json.dumps(new_results, indent=2))
        print(f"Page {page_number}: {len(new_results)} reports saved ({len(results) - len(new_results)} duplicates filtered)")

        skip += PAGE_SIZE
        page_number += 1
        time.sleep(0.5)


if __name__ == "__main__":
    main()