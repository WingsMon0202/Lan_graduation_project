import requests
import json

API_URL = "http://172.20.10.2/API/attendance.php"

payload = {
    "student_id": "SV0020",
    "class_id": 1,
    "status": "present"
}

headers = {
    "Content-Type": "application/json"
}

response = requests.post(API_URL, headers=headers, data=json.dumps(payload))
print(response.text)

