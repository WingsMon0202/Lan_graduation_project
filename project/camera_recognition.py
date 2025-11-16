from picamzero import Camera
import face_recognition
import os
import time
from api_client import push_attendance  # import API client đã viết

# --- Cấu hình ---
KNOWN_FACES_DIR = "known_faces"  # folder ảnh người đã đăng ký
SNAPSHOT_PATH = "snapshot.jpg"
TOLERANCE = 0.5
MODEL = "hog"       # "hog" nhẹ, "cnn" chính xác hơn (Pi 4B nên dùng hog)
DELAY = 10          # chụp ảnh mỗi 10 giây
CLASS_ID = 1        # class mặc định

# --- Load known faces ---
print("Dang tai du lieu khuon mat...")
known_faces = []
known_names = []

for filename in os.listdir(KNOWN_FACES_DIR):
    if not filename.lower().endswith((".png", ".jpg", ".jpeg")):
        continue
    path = os.path.join(KNOWN_FACES_DIR, filename)
    image = face_recognition.load_image_file(path)
    encoding = face_recognition.face_encodings(image)
    if encoding:
        known_faces.append(encoding[0])
        known_names.append(os.path.splitext(filename)[0])

print(f"Da tai {len(known_faces)} khuon mat: {known_names}")

# --- Khoi tao camera ---
cam = Camera()
print("Bat dau nhan dien, chup anh moi 10 giay...")

while True:
    cam.take_photo(SNAPSHOT_PATH)
    print("\nAnh chup, dang xu ly...")

    image = face_recognition.load_image_file(SNAPSHOT_PATH)
    locations = face_recognition.face_locations(image, model=MODEL)
    encodings = face_recognition.face_encodings(image, locations)

    # Danh sach nguoi hien dien trong frame
    present_names = []

    if encodings:
        for face_encoding in encodings:
            results = face_recognition.compare_faces(known_faces, face_encoding, TOLERANCE)
            if True in results:
                match = known_names[results.index(True)]
                print(f"Phat hien: {match}")
                present_names.append(match)
            else:
                print("Khuon mat chua dang ky (Unknown).")
    else:
        print("Khong phat hien khuon mat nao.")

    # --- Push attendance cho tung nguoi trong known_faces ---
    for name in known_names:
        student_id = name.split("_")[0]  # gia su dinh dang "SV0020_Name"
        status = "present" if name in present_names else "absent"
        push_attendance(student_id=student_id, class_id=CLASS_ID, status=status)

    print(f"Doi {DELAY} giay truoc khi chup tiep theo...")
    time.sleep(DELAY)


