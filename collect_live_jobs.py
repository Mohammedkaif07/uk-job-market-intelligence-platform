import os
import time
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv

print("LIVE JOB COLLECTION STARTED")

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")

print("API KEY FOUND:", RAPIDAPI_KEY is not None)

url = "https://jsearch.p.rapidapi.com/search"

headers = {
    "X-RapidAPI-Key": RAPIDAPI_KEY,
    "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
}

search_queries = [
    "data analyst in United Kingdom",
    "business analyst in United Kingdom",
    "bi analyst in United Kingdom",
    "data engineer in United Kingdom",
    "data scientist in United Kingdom",
    "machine learning engineer in United Kingdom",
    "ai engineer in United Kingdom"
]

all_jobs = []

for query in search_queries:

    print(f"\nCollecting: {query}")

    params = {
        "query": query,
        "page": "1",
        "num_pages": "3",
        "country": "gb",
        "date_posted": "month"
    }

    response = requests.get(
        url,
        headers=headers,
        params=params,
        timeout=30
    )

    print("Status:", response.status_code)

    if response.status_code != 200:
        print(response.text[:500])
        continue

    data = response.json()

    jobs = data.get("data", [])

    print("Jobs found:", len(jobs))

    for job in jobs:

        all_jobs.append({

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

            "api_source": "JSearch"

        })

    time.sleep(2)

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