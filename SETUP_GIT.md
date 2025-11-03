# Hướng dẫn Setup Git Repository

## Bước 1: Khởi tạo Git Repository

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/mac_store_app_new

# Khởi tạo git repo
git init

# Kiểm tra .gitignore đã có chưa
# (Đã có sẵn trong Flutter project)
```

## Bước 2: Tạo .gitignore cho Flutter (nếu chưa có)

File `.gitignore` đã có sẵn, nhưng đảm bảo có các mục sau:

- `build/`
- `.dart_tool/`
- `*.iml`
- `.idea/`
- `local.properties`
- `.env` (nếu dùng environment variables)

## Bước 3: Add và Commit files

```bash
# Add tất cả files
git add .

# Commit
git commit -m "Initial commit: Mac Store E-commerce App"
```

## Bước 4: Tạo GitHub Repository

1. Vào GitHub.com
2. Click "New repository"
3. Repository name: `mac-store-flutter-app` (hoặc tên bạn muốn)
4. Chọn Public hoặc Private
5. **KHÔNG** check "Initialize with README" (đã có code rồi)
6. Click "Create repository"

## Bước 5: Push code lên GitHub

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/mac-store-flutter-app.git

# Push code
git branch -M main
git push -u origin main
```

## Bước 6: Setup Backend API Repository (Riêng biệt)

Backend API nên ở repo riêng:

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/backend_api

# Khởi tạo git
git init

# Tạo .gitignore cho Node.js
echo "node_modules/
.env
.env.local
dist/
*.log
.DS_Store" > .gitignore

# Add và commit
git add .
git commit -m "Initial commit: Backend API"

# Tạo repo trên GitHub và push
git remote add origin https://github.com/YOUR_USERNAME/store-backend-api.git
git branch -M main
git push -u origin main
```

## Bước 7: Tạo README cho Flutter App

Tạo README.md với:

- Mô tả app
- Screenshots
- Tech stack
- Setup instructions
- API endpoint (sẽ cập nhật sau khi deploy backend)

## Bước 8: Tạo Release với APK

Sau khi build APK:

```bash
# Build APK
flutter build apk --release

# Tạo tag
git tag -a v1.0.0 -m "First release"

# Push tag
git push origin v1.0.0
```

Trên GitHub:

1. Vào "Releases" > "Create a new release"
2. Chọn tag v1.0.0
3. Upload file `build/app/outputs/flutter-apk/app-release.apk`
4. Add release notes
5. Publish release

---

## Repository Structure gợi ý:

```
mac-store-flutter-app/
├── lib/
├── assets/
├── android/
├── ios/
├── README.md
├── DEPLOYMENT_GUIDE.md
├── BACKEND_DEPLOY.md
└── .gitignore

store-backend-api/ (repo riêng)
├── routes/
├── models/
├── server.js
├── package.json
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## Lưu ý:

1. **KHÔNG commit**:

   - `build/` folder
   - `.env` files (nếu có)
   - `local.properties`
   - API keys/secrets

2. **NÊN commit**:

   - Source code
   - Configuration files
   - Documentation
   - Assets (icons, images)

3. **Backend và Frontend nên tách repo riêng** để:
   - Dễ quản lý
   - Dễ deploy riêng biệt
   - Dễ bảo mật (backend có thể private)
