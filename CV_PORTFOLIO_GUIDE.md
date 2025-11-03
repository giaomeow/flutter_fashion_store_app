# Hướng dẫn Đưa Project vào CV

## Các Cách Tốt Nhất để Showcase Flutter App trong CV

### ✅ Option 1: GitHub Releases (Khuyên dùng - Chuyên nghiệp nhất)

**Ưu điểm:**

- Dễ quản lý nhiều version
- Link ngắn gọn, chuyên nghiệp
- Có thể track download
- Thể hiện được quy trình làm việc chuẩn (version control, release)

**Cách làm:**

1. **Tạo GitHub Release với APK:**

```bash
# Build APK
flutter build apk --release

# Tạo tag
git tag -a v1.0.0 -m "Production Release"

# Push tag
git push origin v1.0.0
```

2. **Trên GitHub:**

   - Vào repository → "Releases" → "Create a new release"
   - Chọn tag v1.0.0
   - Upload file: `build/app/outputs/flutter-apk/app-release.apk`
   - Thêm release notes (mô tả features, screenshots)
   - Publish release

3. **Link sẽ là:**

```
https://github.com/YOUR_USERNAME/mac-store-flutter-app/releases/tag/v1.0.0
```

4. **Trong CV, thêm:**

```
📱 Mac Store E-commerce App
GitHub: github.com/YOUR_USERNAME/mac-store-flutter-app
Download APK: [Link release]
```

---

### ✅ Option 2: Google Drive / Dropbox

**Ưu điểm:**

- Dễ setup
- Có thể share với link công khai

**Cách làm:**

1. Upload APK lên Google Drive
2. Chọn "Get link" → "Anyone with the link"
3. Copy link và thêm vào CV

**Lưu ý:** Tạo folder riêng cho portfolio projects để dễ quản lý

---

### ✅ Option 3: Tạo Portfolio Website (Tốt nhất cho CV)

**Ưu điểm:**

- Chuyên nghiệp nhất
- Có thể showcase nhiều projects
- Có thể thêm screenshots, demo video
- Dễ maintain và update

**Platforms miễn phí:**

- **Vercel** - Deploy React/Next.js site (free)
- **Netlify** - Tương tự Vercel
- **GitHub Pages** - Free hosting cho static site
- **Firebase Hosting** - Free tier

**Cấu trúc Portfolio:**

```
Homepage
├── About
├── Projects
│   ├── Mac Store App
│   │   ├── Screenshots
│   │   ├── Features
│   │   ├── Tech Stack
│   │   ├── Download APK (link to GitHub Release)
│   │   └── GitHub Link
│   └── Other Projects...
└── Contact
```

**Link trong CV:**

```
Portfolio: yourname.dev
Projects: yourname.dev/projects
```

---

### ✅ Option 4: QR Code (Thêm vào CV PDF)

**Ưu điểm:**

- Recruiter có thể scan ngay trên CV in ra
- Trải nghiệm tốt

**Cách làm:**

1. Tạo QR code từ link GitHub Release (dùng https://qr-code-generator.com)
2. Chèn QR code vào CV PDF
3. Thêm text: "Scan to download app"

---

## Cấu trúc Project trong CV

### Format Chuẩn:

```markdown
📱 Mac Store E-commerce App
Flutter | Node.js | MongoDB

• E-commerce mobile app với đầy đủ tính năng shopping
• Authentication, Product browsing, Shopping cart, Order management
• RESTful API với Express.js và MongoDB
• State management với Riverpod

🔗 GitHub: github.com/YOUR_USERNAME/mac-store-flutter-app
📥 Download: [Link to release/Drive]
🎬 Demo: [Link to video/screenshots]

Tech Stack:

- Frontend: Flutter, Dart, Riverpod
- Backend: Node.js, Express.js
- Database: MongoDB
- Tools: Docker, Git, Postman
```

---

## Checklist Trước Khi Đưa Vào CV

### Technical:

- [ ] APK đã build release mode
- [ ] Test APK trên thiết bị thật
- [ ] API URL đã update (production hoặc demo server)
- [ ] Không có debug code/logs
- [ ] App name và package name chuyên nghiệp

### Documentation:

- [ ] README.md có mô tả đầy đủ
- [ ] Screenshots/GIF demo (tối thiểu 3-5 screens)
- [ ] Tech stack được liệt kê
- [ ] Installation/Setup instructions
- [ ] Features list

### GitHub:

- [ ] Code đã push lên GitHub
- [ ] README đẹp và đầy đủ
- [ ] Có screenshots trong README
- [ ] Release đã tạo với APK
- [ ] Commit messages rõ ràng (chứng tỏ quy trình làm việc)

### Portfolio/Share:

- [ ] Link GitHub có trong CV
- [ ] Link download APK có trong CV
- [ ] Screenshots được showcase ở đâu đó
- [ ] Demo video (optional nhưng recommended)

---

## Screenshots Nên Có

Tối thiểu nên có các screenshots sau:

1. **Home Screen** - Banner, categories, products
2. **Product Detail** - Showcase UI
3. **Shopping Cart** - Shopping experience
4. **Checkout/Order** - Order flow
5. **User Profile** - Account management

**Tools để tạo screenshots:**

- Android Studio Emulator
- Physical device với screen recording
- Tools: Snagit, Lightshot, hoặc built-in screenshot

**Format:**

- PNG/JPG chất lượng cao
- Kích thước: 1080x1920 (portrait) hoặc tỷ lệ 9:16
- Đặt trong folder `screenshots/` trong repo

---

## Demo Video (Highly Recommended)

**Nội dung video (30-60 giây):**

1. Mở app
2. Login/Register flow
3. Browse products
4. Add to cart
5. Checkout process
6. Order confirmation

**Platforms để upload:**

- **YouTube** - Unlisted video
- **Loom** - Screen recording với voice
- **Vimeo** - Professional
- **Google Drive** - Simple

**Link trong CV:**

```
🎬 Demo Video: [YouTube/Loom link]
```

---

## README.md Template

Tạo README.md đẹp cho GitHub:

```markdown
# 🛍️ Mac Store E-commerce App

A full-featured e-commerce mobile application built with Flutter.

## 📱 Screenshots

[Insert screenshots here]

## ✨ Features

- 🔐 User Authentication (Login/Register)
- 🏠 Home with banners and categories
- 🛒 Shopping Cart
- 📦 Order Management
- 👤 User Profile
- 🔍 Product Search
- 📱 Beautiful UI/UX

## 🛠️ Tech Stack

### Frontend

- Flutter
- Dart
- Riverpod (State Management)
- Google Fonts

### Backend

- Node.js
- Express.js
- MongoDB
- JWT Authentication

## 📦 Installation

### Prerequisites

- Flutter SDK
- Android Studio / Xcode
- Node.js (for backend)

### Setup

1. Clone repository
2. Install dependencies: `flutter pub get`
3. Update API URL in `lib/global_variables.dart`
4. Run: `flutter run`

## 📥 Download APK

[![Download APK](https://img.shields.io/badge/Download-APK-blue)](https://github.com/YOUR_USERNAME/mac-store-flutter-app/releases)

Or visit [Releases](https://github.com/YOUR_USERNAME/mac-store-flutter-app/releases) page.

## 🚀 Demo

Watch demo video: [Link to video]

## 📝 License

MIT License
```

---

## Quick Commands để Chuẩn Bị

```bash
# 1. Build APK
flutter clean
flutter pub get
flutter build apk --release

# 2. APK location
# build/app/outputs/flutter-apk/app-release.apk

# 3. Create GitHub release
git tag -a v1.0.0 -m "Production Release"
git push origin v1.0.0

# 4. Upload APK to GitHub Releases (via web)
# Go to: https://github.com/YOUR_USERNAME/mac-store-flutter-app/releases/new

# 5. Take screenshots (optional)
# Use emulator or physical device
```

---

## Tips Quan Trọng

1. **API URL:**

   - Nếu backend chưa deploy production, có thể dùng demo server
   - Hoặc note trong README: "Requires backend server"
   - Hoặc deploy backend lên Railway/Render (free) để demo

2. **Privacy:**

   - Không commit API keys, secrets
   - Dùng environment variables
   - Check `.gitignore`

3. **Professionalism:**

   - App name rõ ràng, không có placeholder
   - Package name: `com.yourname.macstore` (không phải `com.example`)
   - Icon app đẹp (không dùng default Flutter icon)

4. **Documentation:**
   - README càng đẹp càng tốt
   - Code comments rõ ràng
   - Commit messages có ý nghĩa

---

## Recommended Structure cho CV

```
PROJECTS SECTION:

📱 Mac Store E-commerce App | Flutter, Node.js, MongoDB
   Full-featured shopping app with authentication, cart, and order management
   🔗 github.com/YOUR_USERNAME/mac-store-flutter-app
   📥 Download APK
   🎬 Demo Video

   • Built responsive UI with Flutter and Riverpod state management
   • Developed RESTful API with Express.js and MongoDB
   • Implemented JWT authentication and secure user sessions
   • Deployed backend with Docker
```

---

## Final Checklist

- [ ] APK built và tested
- [ ] GitHub repo có README đẹp
- [ ] GitHub Release với APK
- [ ] Screenshots (3-5 images)
- [ ] Demo video (optional)
- [ ] Link trong CV
- [ ] Code clean, well-documented
- [ ] Backend deployed (hoặc có note trong README)
