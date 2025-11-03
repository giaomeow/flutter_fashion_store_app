# Hướng dẫn Setup Git Repository & Deploy

## 1. Setup Git cho Flutter App

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/mac_store_app_new

# Khởi tạo git (nếu chưa có)
git init

# Kiểm tra status
git status

# Add tất cả files
git add .

# Commit
git commit -m "Initial commit: Mac Store E-commerce Flutter App

Features:
- User authentication (Login/Register)
- Product browsing (Home, Category, Stores)
- Shopping cart
- Order management
- User profile
- Search functionality"

# Tạo repo trên GitHub, sau đó:
git remote add origin https://github.com/YOUR_USERNAME/mac-store-flutter-app.git
git branch -M main
git push -u origin main
```

## 2. Setup Git cho Backend API (Repo riêng)

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/backend_api

# Khởi tạo git
git init

# Tạo .gitignore cho Node.js
cat > .gitignore << EOF
node_modules/
.env
.env.local
.env.production
dist/
*.log
.DS_Store
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

# Add và commit
git add .
git commit -m "Initial commit: Store Backend API

Tech Stack:
- Node.js/Express
- MongoDB/Mongoose
- JWT Authentication
- Docker support"

# Tạo repo trên GitHub và push
git remote add origin https://github.com/YOUR_USERNAME/store-backend-api.git
git branch -M main
git push -u origin main
```

## 3. Deploy Backend API lên Server

### Option A: Deploy với Docker (Khuyên dùng)

Backend đã có sẵn `Dockerfile` và `docker-compose.yml`.

**Trên server:**

```bash
# Clone repo
git clone https://github.com/YOUR_USERNAME/store-backend-api.git
cd store-backend-api

# Build và run với Docker Compose
docker-compose up -d

# Check status
docker-compose ps

# Xem logs
docker-compose logs -f
```

**Sau khi deploy, lấy URL của API:**

- Nếu có domain: `https://api.yourdomain.com`
- Nếu chỉ có IP: `http://YOUR_SERVER_IP:3000`

### Option B: Deploy lên Railway/Render (Miễn phí)

1. **Railway:**

   - Connect GitHub repo
   - Auto detect Node.js
   - Add MongoDB service
   - Deploy → Lấy URL: `https://your-app.railway.app`

2. **Render:**
   - Tương tự Railway
   - Free tier available

## 4. Cập nhật API URL trong Flutter App

### Cách 1: Dùng script (Nhanh nhất)

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/mac_store_app_new

# Chạy script để update URL
./update_api_url.sh https://your-api-domain.com

# Hoặc với IP
./update_api_url.sh http://YOUR_SERVER_IP:3000
```

### Cách 2: Sửa thủ công

Mở `lib/global_variables.dart` và thay đổi:

```dart
// Development
String uri = "http://192.168.1.2:300";

// Production (sau khi deploy)
String uri = "https://your-api-domain.com";
```

## 5. Build APK với Production URL

```bash
# Đảm bảo đã update API URL
# Sau đó build
flutter clean
flutter pub get
flutter build apk --release

# APK sẽ ở: build/app/outputs/flutter-apk/app-release.apk
```

## 6. Tạo GitHub Release với APK

```bash
# Tag version
git tag -a v1.0.0 -m "Production release"

# Push tag
git push origin v1.0.0
```

Trên GitHub:

1. Vào Releases > "Create a new release"
2. Chọn tag v1.0.0
3. Upload file `app-release.apk`
4. Add release notes
5. Publish

## 7. Checklist trước khi deploy

### Backend:

- [ ] Test API trên local
- [ ] Cấu hình MongoDB (Atlas hoặc Docker)
- [ ] Setup CORS cho phép requests từ Flutter app
- [ ] Test API endpoints
- [ ] Deploy lên server/Docker
- [ ] Test API trên production URL
- [ ] Setup domain/SSL (nếu có)

### Flutter App:

- [ ] Update API URL trong `global_variables.dart`
- [ ] Test app với production API
- [ ] Build APK release
- [ ] Test APK trên thiết bị thật
- [ ] Upload APK lên GitHub Releases
- [ ] Tạo README với screenshots

## 8. Cấu trúc Repository

```
mac-store-flutter-app/ (Public/Private)
├── lib/
├── assets/
├── README.md
├── DEPLOYMENT_GUIDE.md
└── ...

store-backend-api/ (Nên Private)
├── routes/
├── models/
├── server.js
├── Dockerfile
├── docker-compose.yml
└── ...
```

---

## Quick Commands Summary

```bash
# 1. Update API URL
./update_api_url.sh https://your-api-domain.com

# 2. Build APK
flutter clean && flutter pub get && flutter build apk --release

# 3. Git push
git add .
git commit -m "Update API URL for production"
git push

# 4. Create release (on GitHub web)
# Upload APK to Releases
```
