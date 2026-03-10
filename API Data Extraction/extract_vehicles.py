import requests
import pandas as pd
import time
import os

url = "https://data.gov.il/api/3/action/datastore_search"
resource_id = "053cea08-09bc-40ec-8f7a-156f0677aff3"
output_file = "mrr_fct_vehicle.csv"
checkpoint_file = "offset_checkpoint.txt"
limit = 10000
max_retries = 3

session = requests.Session()

# Resume מנקודת checkpoint
if os.path.exists(checkpoint_file):
    with open(checkpoint_file, "r") as f:
        offset = int(f.read().strip())
    print(f"Resuming from offset {offset}")
    first_chunk = not os.path.exists(output_file) or os.path.getsize(output_file) == 0
else:
    offset = 0
    first_chunk = True

while True:
    params = {
        "resource_id": resource_id,
        "limit": limit,
        "offset": offset
    }

    response = None
    for attempt in range(1, max_retries + 1):
        try:
            response = session.get(url, params=params, timeout=90)
            response.raise_for_status()
            break
        except (requests.exceptions.ReadTimeout,
                requests.exceptions.ConnectionError,
                requests.exceptions.HTTPError) as e:
            print(f"Error at offset {offset}, attempt {attempt}/{max_retries}: {e}")
            if attempt < max_retries:
                time.sleep(5)
            else:
                print(f"Failed after {max_retries} attempts. Stopping.")
                raise

    data = response.json()

    if not data.get("success"):
        raise ValueError(f"API error at offset {offset}")

    records = data["result"]["records"]

    if not records:
        print(f"Total records fetched: {offset}")
        if os.path.exists(checkpoint_file):
            os.remove(checkpoint_file)
        break

    df_chunk = pd.DataFrame(records).astype("string")
    df_chunk.to_csv(
        output_file,
        mode="w" if first_chunk else "a",
        index=False,
        header=first_chunk,
        encoding="utf-8-sig"
    )
    first_chunk = False

    offset += len(records)

    with open(checkpoint_file, "w") as f:
        f.write(str(offset))

    print(f"Total offset so far: {offset}")