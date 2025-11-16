import requests
import json
import time

API_URL = "http://172.20.10.2/attendance_api/attendance.php"
MAX_RETRIES = 3
RETRY_DELAY = 2  # giây

def push_attendance(student_id, class_id=1, status="present"):
    """
    Gửi attendance lên server.
    student_id: SVxxxx
    class_id: mặc định 1
    status: "present" hoặc "absent"
    """
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

            # HTTP lỗi
            if response.status_code != 200:
                print(f"HTTP error {response.status_code}: {response.text}")
                time.sleep(RETRY_DELAY)
                continue

            # Parse JSON
            try:
                res_json = response.json()
            except json.JSONDecodeError:
                print(f"Không parse được JSON: {response.text}")
                time.sleep(RETRY_DELAY)
                continue

            # Kiểm tra lỗi từ server
            if res_json.get("ok") == True:
                print(f"Push thành công: {student_id}, ID inserted: {res_json.get('id')}")
                return True
            elif "error" in res_json:
                print(f"Lỗi từ server: {res_json['error']}")
                time.sleep(RETRY_DELAY)
            else:
                print(f"Push thất bại: {res_json}")
                time.sleep(RETRY_DELAY)

        except requests.exceptions.RequestException as e:
            print(f"Lỗi kết nối API: {e}")
            time.sleep(RETRY_DELAY)

    print(f"Push thất bại sau {MAX_RETRIES} lần: {student_id}")
    return False


