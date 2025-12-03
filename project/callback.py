import threading
import time
import face_recognition
from picamzero import Camera
import os

KNOWN_FACES_DIR = "known_faces"
SNAPSHOT_PATH = "snapshot.jpg"
TOLERANCE = 0.5
MODEL = "hog"
DELAY = 10

# --- Load known faces ---
known_faces = []
known_names = []

for name in os.listdir(KNOWN_FACES_DIR):
    if name.lower().endswith((".jpg", ".png", ".jpeg")):
        img = face_recognition.load_image_file(os.path.join(KNOWN_FACES_DIR, name))
        enc = face_recognition.face_encodings(img)[0]
        known_faces.append(enc)
        known_names.append(os.path.splitext(name)[0])

print(f"Loaded faces: {known_names}")

cam = Camera()

# Sự kiện giống như interrupt
capture_event = threading.Event()

def capture_timer():
    """Bộ hẹn giờ tạo sự kiện giống interrupt"""
    while True:
        capture_event.set()
        time.sleep(DELAY)

def process_image():
    """Xử lý khi event xảy ra"""
    while True:
        capture_event.wait()          # Đợi "ngắt"
        capture_event.clear()

        cam.take_photo(SNAPSHOT_PATH)
        print("📸 Captured, processing...")

        image = face_recognition.load_image_file(SNAPSHOT_PATH)
        locations = face_recognition.face_locations(image, model=MODEL)
        encodings = face_recognition.face_encodings(image, locations)

        if not encodings:
            print(" No faces detected.")
        else:
            for enc in encodings:
                results = face_recognition.compare_faces(known_faces, enc, TOLERANCE)
                if True in results:
                    name = known_names[results.index(True)]
                    print(f" Detected: {name}")
                else:
                    print(" Unknown face")

        print(f"⏳ Waiting {DELAY} seconds...\n")

# --- Start threads ---
threading.Thread(target=capture_timer, daemon=True).start()
threading.Thread(target=process_image, daemon=True).start()

print("System running with callback-style event...")
while True:
    time.sleep(1)
