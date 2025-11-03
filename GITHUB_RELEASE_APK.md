# Hướng dẫn Đẩy APK lên GitHub Releases

## ✅ Có thể đẩy APK lên GitHub Releases

GitHub Releases là cách tốt nhất để share APK:

- ✅ Chuyên nghiệp
- ✅ Dễ quản lý version
- ✅ Link ngắn gọn
- ✅ Có thể track download
- ✅ Miễn phí

---

## 🚀 Cách 1: Qua GitHub Web UI (Dễ nhất)

### Bước 1: Build APK

```bash
flutter build apk --release
```

APK sẽ ở: `build/app/outputs/flutter-apk/app-release.apk`

### Bước 2: Tạo Tag

```bash
# Tạo tag cho version
git tag -a v1.0.0 -m "Production Release v1.0.0"

# Push tag lên GitHub
git push origin v1.0.0
```

### Bước 3: Tạo Release trên GitHub

1. **Vào GitHub repository:**

   - Mở repo của bạn trên GitHub
   - Click tab **"Releases"** (ở bên phải, dưới About)
   - Click **"Create a new release"**

2. **Điền thông tin:**

   - **Choose a tag:** Chọn tag v1.0.0 (hoặc tạo mới)
   - **Release title:** `v1.0.0 - Production Release` (hoặc tên bạn muốn)
   - **Description:** Thêm mô tả về release:

     ```markdown
     ## 🎉 First Production Release

     ### Features:

     - User authentication
     - Product browsing
     - Shopping cart
     - Order management
     - User profile

     ### 📱 Install:

     Download APK below and install on Android device
     ```

3. **Upload APK:**

   - Kéo thả file `app-release.apk` vào phần **"Attach binaries"**
   - Hoặc click "selecting them" và chọn file

4. **Publish:**
   - Click **"Publish release"**

### Bước 4: Xem Release

Sau khi publish, bạn sẽ có link như:

```
https://github.com/YOUR_USERNAME/mac-store-flutter-app/releases/tag/v1.0.0
```

Người dùng có thể download APK từ đây!

---

## 🚀 Cách 2: Dùng GitHub CLI (Nhanh hơn)

### Cài GitHub CLI:

```bash
# macOS
brew install gh

# Hoặc download từ: https://cli.github.com/
```

### Login:

```bash
gh auth login
```

### Tạo Release với APK:

```bash
# Build APK trước
flutter build apk --release

# Tạo release và upload APK
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "v1.0.0 - Production Release" \
  --notes "First production release of Mac Store App"
```

**Các options khác:**

```bash
# Với description file
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "v1.0.0" \
  --notes-file RELEASE_NOTES.md

# Draft release (chưa publish)
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --draft \
  --title "v1.0.0"

# Prerelease
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --prerelease \
  --title "v1.0.0 - Beta"
```

---

## 🚀 Cách 3: Script Tự Động

Tạo script để tự động build và release:

```bash
#!/bin/bash
# release_apk.sh

VERSION=${1:-"v1.0.0"}
TAG_NAME=$VERSION
RELEASE_NOTES="Release $VERSION

Features:
- Mac Store E-commerce App
- Full shopping experience
"

echo "🚀 Building APK..."
flutter clean
flutter pub get
flutter build apk --release

if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

echo "📦 Creating release..."
gh release create $TAG_NAME \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "$VERSION - Production Release" \
  --notes "$RELEASE_NOTES"

echo ""
echo "✅ Release created: https://github.com/YOUR_USERNAME/REPO_NAME/releases/tag/$TAG_NAME"
```

**Sử dụng:**

```bash
chmod +x release_apk.sh
./release_apk.sh v1.0.0
```

---

## 📋 Checklist Trước Khi Release

- [ ] Test APK trên thiết bị thật
- [ ] Update API URL cho production (nếu cần)
- [ ] Kiểm tra app name, version trong `pubspec.yaml`
- [ ] Build APK release mode
- [ ] Test APK không crash
- [ ] Chuẩn bị release notes (mô tả features)

---

## 🔧 Tips

### 1. Versioning

Nên dùng semantic versioning:

- `v1.0.0` - Major release
- `v1.0.1` - Bug fix
- `v1.1.0` - New features

### 2. Release Notes Template

```markdown
## 🎉 v1.0.0 - Production Release

### ✨ Features:

- User authentication (Login/Register)
- Product browsing and search
- Shopping cart
- Order management
- User profile

### 🐛 Bug Fixes:

- Fixed cart update issue
- Fixed navigation bug

### 📱 Install:

1. Download APK below
2. Enable "Install from Unknown Sources" on Android
3. Install APK
4. Open and enjoy!

### 🔗 Links:

- Source Code: [GitHub](https://github.com/username/repo)
- Live Demo: [Web App](https://your-app.vercel.app)
```

### 3. Multiple APKs (Split APKs)

Nếu build split APK (nhỏ hơn):

```bash
flutter build apk --split-per-abi --release
```

Sẽ có nhiều file:

- `app-arm64-v8a-release.apk` (cho ARM64)
- `app-armeabi-v7a-release.apk` (cho ARM32)
- `app-x86_64-release.apk` (cho x86_64)

Upload tất cả lên release!

### 4. APK Size

APK thường 20-50MB. GitHub cho phép upload file tới 100MB (free) hoặc 2GB (Pro).

---

## 📱 Link APK trong CV/README

Sau khi tạo release, bạn có thể:

1. **Link trực tiếp:**

```
Download APK: https://github.com/username/repo/releases/latest
```

2. **Badge trong README:**

```markdown
[![Download APK](https://img.shields.io/badge/Download-APK-blue)](https://github.com/username/repo/releases/latest)
```

3. **QR Code:**

- Tạo QR code từ release link
- Thêm vào README hoặc CV

---

## 🚨 Lưu ý Quan Trọng

### 1. Không commit APK vào Git

APK file lớn, không nên commit vào git. Thêm vào `.gitignore`:

```
# APK files
*.apk
build/app/outputs/
```

### 2. API URL

Đảm bảo API URL trong `global_variables.dart` đã update cho production trước khi build release APK.

### 3. Keystore (Cho Production)

Nếu muốn publish lên Play Store sau này, cần dùng keystore:

```bash
# Tạo keystore (chỉ làm 1 lần)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure trong android/app/build.gradle
```

---

## ✅ Quick Commands

```bash
# 1. Build APK
flutter build apk --release

# 2. Tạo tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 3. Tạo release (nếu dùng gh CLI)
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "v1.0.0" \
  --notes "Release notes here"

# Hoặc qua GitHub web UI (dễ hơn)
```

---

## 🎯 Ví dụ Workflow Hoàn Chỉnh

```bash
# 1. Update version trong pubspec.yaml
version: 1.0.0+1

# 2. Commit changes
git add .
git commit -m "Prepare v1.0.0 release"
git push

# 3. Build APK
flutter clean
flutter pub get
flutter build apk --release

# 4. Test APK trên thiết bị
# (Transfer và test)

# 5. Tạo tag
git tag -a v1.0.0 -m "v1.0.0 Production Release"
git push origin v1.0.0

# 6. Tạo release trên GitHub
# - Vào Releases → Create new release
# - Chọn tag v1.0.0
# - Upload app-release.apk
# - Thêm release notes
# - Publish

# Done! ✅
```
