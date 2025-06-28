# 👁️‍🗨️ Flutter Face Detection App

A Flutter app for real-time face detection and facial analysis using the device camera. It displays predictions for **emotions**, **age**, and **gender** over the live camera preview, with Lottie animations to enhance the experience.

---

## 🚀 Features

- 🔍 Real-time face detection using the camera
- 🎭 Emotion, age, and gender recognition
- 📁 Analyze images from the gallery
- ✨ Lottie animations overlay for visual feedback
- ☁️ Optional cloud API support (Luxand)

---

## 📸 Screenshots

| Preview | Result |
|--------|--------|
| ![screenshot1](screenshots/screenshot1.png) | ![screenshot2](screenshots/screenshot2.png) |

> 📝 Replace these with actual screenshots from your app.

---

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 2. Get Luxand API Token

1. Go to [https://www.luxand.cloud/](https://www.luxand.cloud/) and sign up.
2. Copy your **API Token**.
3. Replace "API_KEY" in file `lib\utils\api_client.dart` with your api key:

```dart
class ApiClient {
  static const String token = "API_KEY";
```

### 3. Install Dependencies & Run

```bash
flutter pub get
flutter run
```


