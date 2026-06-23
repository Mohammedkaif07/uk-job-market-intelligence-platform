"""
collect_live_jobs.py

Standalone script that calls the JSearch API (via RapidAPI) to collect live UK job
postings for 5 data-related roles. Designed to be run on demand — or scheduled with
cron / Windows Task Scheduler — to refresh the live job feed used by Power BI.

Usage:
    python collect_live_jobs.py
"""

import os
import time
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv

print("LIVE JOB COLLECTION STARTED")

# ── Load API key securely from .env ──────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
print("API KEY FOUND:", RAPIDAPI_KEY is not None)

if not RAPIDAPI_KEY:
    raise SystemExit(
        "No RAPIDAPI_KEY found. Create a .env file in the project root with:\n"
        "RAPIDAPI_KEY=your_actual_key_here"
    )

url = "https://jsearch.p.rapidapi.com/search"
headers = {
    "X-RapidAPI-Key": RAPIDAPI_KEY,
    "X-RapidAPI-Host": "jsearch.p.rapidapi.com",
}

# ── The 5 data roles tracked across this whole project ───────────────────────
search_queries = [
    "data analyst in United Kingdom",
    "data engineer in United Kingdom",
    "data scientist in United Kingdom",
    "ai engineer in United Kingdom",
    "ml engineer in United Kingdom",
]

all_jobs = []

for query in search_queries:
    print(f"\nCollecting: {query}")

    params = {
        "query": query,
        "page": "1",
        "num_pages": "3",
        "country": "gb",
        "date_posted": "month",
    }

    response = requests.get(url, headers=headers, params=params, timeout=30)
    print("Status:", response.status_code)

    if response.status_code != 200:
        print(response.text[:500])
        continue

    data = response.json()
    jobs = data.get("data", [])
    print("Jobs found:", len(jobs))

    for job in jobs:
        all_jobs.append(
            {
                "job_id": job.get("job_id"),
                "job_title": job.get("job_title"),
                "company": job.get("employer_name"),
                "location": job.get("job_location"),
                "country": job.get("job_country"),
                "employment_type": job.get("job_employment_type"),
                "job_description": job.get("job_description"),
                "date_posted": job.get("job_posted_at_datetime_utc"),
                "job_url": job.get("job_apply_link"),
                "publisher": job.get("job_publisher"),
                "is_remote": job.get("job_is_remote"),
                "salary_min": job.get("job_min_salary"),
                "salary_max": job.get("job_max_salary"),
                "salary_period": job.get("job_salary_period"),
                "search_query": query,
                "role_category": query.replace(" in United Kingdom", "").title(),
                "api_source": "JSearch",
            }
        )

    time.sleep(2)  # respect API rate limits between requests

df = pd.DataFrame(all_jobs)

if not df.empty:
    df.drop_duplicates(subset=["job_id"], inplace=True)
    output_path = BASE_DIR / "data" / "scraped" / "live_jobs.csv"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False, encoding="utf-8")

    print("\nLIVE JOBS SAVED SUCCESSFULLY")
    print("Total jobs:", len(df))
    print("Saved to:", output_path)
    print(df.head())
else:
    print("\nNo jobs were collected. Check your API key and rate limits.")
