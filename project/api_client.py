import requests
import json
import time

API_URL = "http://172.20.10.2/API/attendance.php"
MAX_RETRIES = 1       # số lần thử lại
RETRY_DELAY = 2       # giây giữa các lần retry

def push_attendance(student_id, class_id=1, status="present"):
    payload = {
        "student_id": student_id,
        "class_id": class_id,
        "status": status
    }

    headers = {
        "Content-Type": "application/json"
    }

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"Sending JSON (attempt {attempt}): {payload}")
            response = requests.post(API_URL, headers=headers, data=json.dumps(payload), timeout=5)

            # Kiểm tra HTTP status
            if response.status_code != 200:
                time.sleep(RETRY_DELAY)
                continue

            # Parse JSON trả về
            try:
                res_json = response.json()
            except json.JSONDecodeError:
                time.sleep(RETRY_DELAY)
                continue

        except requests.exceptions.RequestException as e:
            print(f"ok")
            time.sleep(RETRY_DELAY)

    return False
