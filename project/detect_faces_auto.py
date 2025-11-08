from picamzero import Camera
import face_recognition
import os
import time
import cv2

KNOWN_FACES_DIR = "known_faces"
SNAPSHOT_PATH = "snapshot.jpg"
TOLERANCE = 0.5
MODEL = "hog" 
DELAY = 10  

print("Đang tải dữ liệu khuôn mặt...")

known_faces = []
known_names = []

for name in os.listdir(KNOWN_FACES_DIR):
    if not name.lower().endswith((".png", ".jpg", ".jpeg")):
        continue

    image_path = os.path.join(KNOWN_FACES_DIR, name)
    image = face_recognition.load_image_file(image_path)
    encoding = face_recognition.face_encodings(image)[0]
    known_faces.append(encoding)
    known_names.append(os.path.splitext(name)[0])

print(f"Đã tải {len(known_faces)} khuôn mặt: {known_names}")

# Khởi tạo camera Pi
cam = Camera()
print("Bắt đầu nhận diện, chụp ảnh mỗi 10 giây...")

while True:
    # Chụp ảnh từ camera
    cam.take_photo(SNAPSHOT_PATH)
    print("📸 Đã chụp ảnh, đang xử lý...")

    # Đọc ảnh vừa chụp
    image = face_recognition.load_image_file(SNAPSHOT_PATH)
    locations = face_recognition.face_locations(image, model=MODEL)
    encodings = face_recognition.face_encodings(image, locations)

    if not encodings:
        print(" Không phát hiện khuôn mặt nào.")
    else:
        for face_encoding in encodings:
            results = face_recognition.compare_faces(known_faces, face_encoding, TOLERANCE)
            if True in results:
                match = known_names[results.index(True)]
                print(f" Phát hiện: {match}")
            else:
                print(" Khuôn mặt chưa đăng ký (Unknown).")

    print(" Đợi 10 giây...\n")
    time.sleep(DELAY)

