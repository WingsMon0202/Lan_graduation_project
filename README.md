# Attendance Admin Web (Flutter)

A minimal Flutter **web admin** for your AI edge attendance system (Raspberry Pi + camera + XAMPP PHP API).

## Quick start
```bash
# 1) Create a new flutter project (or reuse any empty project)
flutter create attendance_admin_web
cd attendance_admin_web

# 2) Replace pubspec.yaml and lib/ with the ones from this bundle
#    (copy files over the project)
# 3) Get packages
flutter pub get

# 4) Run in web
flutter run -d chrome
# or build: flutter build web
```

## Configure API base URL
Open the app → **Settings** → set your API base URL, e.g.
```
http://172.20.10.5/attendance_api
```

## Expected PHP endpoints
- GET  /students.php
- POST /students_add.php   (JSON: {student_id, name, class_id})
- POST /students_delete.php (JSON: {student_id})

- GET  /classes.php
- POST /classes_add.php    (JSON: {class_name, teacher})
- POST /classes_delete.php (JSON: {id})

- GET  /attendance.php     (list)
- POST /attendance.php     (JSON: {student_id, class_id, status})

- GET  /logs.php

> The Flutter app functions if you only have students.php, classes.php, attendance.php, logs.php. 
> Add the *_add.php and *_delete.php endpoints to enable create/delete from UI.