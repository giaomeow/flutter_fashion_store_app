# Hướng dẫn Deploy Backend API

## Tổng quan

Backend API của bạn hiện tại ở: `../backend_api/`

Sau khi deploy backend lên server (Docker, VPS, Cloud), bạn cần cập nhật URI trong Flutter app.

---

## Option 1: Thay đổi URI trực tiếp (Đơn giản nhất)

### Trong Flutter App:

Chỉ cần sửa file `lib/global_variables.dart`:

```dart
// Development (local)
String uri = "http://192.168.1.2:300";

// Production (sau khi deploy)
String uri = "https://your-api-domain.com";  // hoặc IP server
```

**Sau đó build lại APK:**

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## Option 2: Dùng Environment Variables (Khuyên dùng)

### Bước 1: Cài package `flutter_dotenv`

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Và assets:

```yaml
flutter:
  assets:
    - .env
    - .env.production
```

### Bước 2: Tạo file `.env` và `.env.production`

`.env` (cho development):

```
API_URL=http://192.168.1.2:300
```

`.env.production` (cho production):

```
API_URL=https://your-api-domain.com
```

### Bước 3: Cập nhật `global_variables.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get uri => dotenv.env['API_URL'] ?? 'http://192.168.1.2:300';
```

### Bước 4: Load env trong `main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env cho production, .env.production cho release
  await dotenv.load(fileName: ".env.production");

  runApp(ProviderScope(child: const MyApp()));
}
```

### Bước 5: Build với environment

```bash
# Copy .env.production thành .env trước khi build
cp .env.production .env
flutter build apk --release
```

---

## Option 3: Build Flavors (Chuyên nghiệp nhất)

Tạo nhiều build config cho dev/staging/production với URI khác nhau.

---

## Deploy Backend API lên Server

### A. Với Docker (Khuyên dùng)

1. **Tạo Dockerfile cho backend:**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

2. **Tạo docker-compose.yml:**

```yaml
version: "3.8"
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGO_URI=mongodb://mongo:27017/storeapp
    depends_on:
      - mongo

  mongo:
    image: mongo:latest
    volumes:
      - mongo_data:/data/db
    ports:
      - "27017:27017"

volumes:
  mongo_data:
```

3. **Deploy lên server:**

```bash
# Trên server
git clone your-backend-repo
cd backend_api
docker-compose up -d
```

### B. Deploy lên các Platform miễn phí

#### 1. Railway.app (Dễ nhất - Free tier)

- Connect GitHub repo
- Tự động detect Node.js
- Có MongoDB addon
- Auto deploy khi push code

#### 2. Render.com (Free tier)

- Tương tự Railway
- Free tier: 512MB RAM

#### 3. Fly.io (Free tier)

- Docker-based
- Global CDN

#### 4. Heroku (Paid, nhưng có free tier cũ)

- Dễ deploy
- Có MongoDB addon

### C. VPS (DigitalOcean, AWS EC2, etc.)

1. **Cài Docker trên VPS:**

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

2. **Clone và deploy:**

```bash
git clone your-backend-repo
cd backend_api
docker-compose up -d
```

3. **Setup Nginx reverse proxy (optional):**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}
```

4. **Setup SSL với Let's Encrypt:**

```bash
sudo certbot --nginx -d your-domain.com
```

---

## Checklist Deploy

### Backend:

- [ ] Test API trên local
- [ ] Cấu hình MongoDB connection string
- [ ] Setup CORS để cho phép requests từ Flutter app
- [ ] Test API trên server
- [ ] Setup domain/SSL (nếu có)

### Flutter App:

- [ ] Cập nhật URI trong `global_variables.dart`
- [ ] Test app với production API
- [ ] Build APK release
- [ ] Test APK trên thiết bị thật

---

## CORS Configuration (Quan trọng!)

Đảm bảo backend có CORS cho phép Flutter app:

```javascript
// Backend code
const cors = require("cors");
app.use(
  cors({
    origin: "*", // hoặc domain cụ thể
    credentials: true,
  })
);
```

---

## Lưu ý về MongoDB

Nếu dùng MongoDB Atlas (cloud):

- Free tier: 512MB
- Connection string sẽ là: `mongodb+srv://username:password@cluster.mongodb.net/dbname`

Nếu dùng MongoDB trên server:

- Cài MongoDB trong Docker container
- Connection string: `mongodb://localhost:27017/dbname`

---

## Quick Deploy Commands

### Railway:

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### Render:

1. Connect GitHub repo tại render.com
2. Chọn "Web Service"
3. Build command: `npm install`
4. Start command: `node server.js`
5. Auto deploy

### Docker:

```bash
# Build image
docker build -t store-api .

# Run container
docker run -p 3000:3000 store-api

# Với docker-compose
docker-compose up -d
```
