# Nên Deploy Web hay APK cho CV?

## Phân tích: Web vs APK

### ✅ Web Deployment (Khuyên dùng cho CV)

**Ưu điểm:**

- ✅ **Dễ truy cập nhất** - Recruiter chỉ cần click link, không cần download/install
- ✅ **Không cần thiết bị Android** - Chạy được trên mọi trình duyệt (Desktop, Mobile, iOS, Android)
- ✅ **Tốc độ demo nhanh** - Mở ngay trong browser, không cần cài đặt
- ✅ **Professional** - Thể hiện khả năng deploy full-stack
- ✅ **Dễ share** - Chỉ cần gửi link trong CV/email
- ✅ **Miễn phí hosting** - Vercel, Netlify, Firebase Hosting (free tier)
- ✅ **SEO friendly** - Có thể tìm thấy qua Google

**Nhược điểm:**

- ❌ Performance có thể kém hơn native app một chút
- ❌ Một số tính năng native không hoạt động (push notification, camera access có thể cần setup thêm)
- ❌ File size lớn hơn khi tải lần đầu (nhưng có caching)

---

### 📱 APK Deployment

**Ưu điểm:**

- ✅ Performance tốt nhất (native)
- ✅ Đầy đủ tính năng native (camera, notifications, etc.)
- ✅ Thể hiện được khả năng build production app
- ✅ Phù hợp nếu apply vào công ty mobile-first

**Nhược điểm:**

- ❌ Cần thiết bị Android để test
- ❌ Recruiter phải download và install (mất thời gian)
- ❌ Khó demo hơn (không thể click link và xem ngay)
- ❌ File size lớn (20-50MB)

---

## 🎯 Khuyến nghị cho CV

### **Option 1: Deploy CẢ HAI (Tốt nhất) ⭐**

**Cách tốt nhất:** Có cả Web và APK

```
📱 Mac Store E-commerce App

🌐 Live Demo: https://mac-store.vercel.app
📥 Download APK: [GitHub Releases]
📂 Source Code: [GitHub]
```

**Lý do:**

- Recruiter có thể xem ngay trên web (tiện lợi)
- Có APK để show khả năng build production (chuyên nghiệp)
- Thể hiện được cả frontend và deployment skills

### **Option 2: Chỉ Web (Nếu muốn đơn giản)**

Nếu chỉ muốn một cách:

- ✅ **Deploy Web** - Dễ truy cập nhất cho recruiter
- APK có thể để sau (khi nào cần thì build)

### **Option 3: Chỉ APK (Không khuyên dùng cho CV)**

Chỉ dùng APK nếu:

- Công ty bạn apply chỉ làm mobile apps
- Recruiter chắc chắn có thiết bị Android để test

---

## 📊 So sánh nhanh

| Tiêu chí         | Web                | APK                       | Winner  |
| ---------------- | ------------------ | ------------------------- | ------- |
| Dễ truy cập      | ✅ Chỉ cần link    | ❌ Cần download + install | **Web** |
| Performance      | ⚠️ Tốt             | ✅ Rất tốt                | APK     |
| Demo nhanh       | ✅ Ngay lập tức    | ❌ Mất thời gian          | **Web** |
| Professional     | ✅✅               | ✅                        | **Web** |
| Tính năng native | ⚠️ Một số không có | ✅ Đầy đủ                 | APK     |
| Share trong CV   | ✅ Rất dễ          | ❌ Phức tạp hơn           | **Web** |
| Tốt cho CV       | ✅✅✅             | ✅✅                      | **Web** |

---

## 🚀 Hướng dẫn Deploy Web (Nhanh nhất)

### Cách 1: Vercel (Khuyên dùng - 5 phút)

```bash
# 1. Build web
flutter build web --release

# 2. Install Vercel CLI (nếu chưa có)
npm i -g vercel

# 3. Deploy
cd build/web
vercel --prod

# Hoặc deploy trực tiếp từ folder
vercel build/web --prod
```

**Kết quả:** URL như `https://mac-store.vercel.app`

**Tự động deploy:** Connect GitHub repo, mỗi lần push sẽ tự deploy.

---

### Cách 2: Netlify (Tương tự Vercel)

```bash
# 1. Build web
flutter build web --release

# 2. Install Netlify CLI
npm i -g netlify-cli

# 3. Deploy
cd build/web
netlify deploy --prod
```

---

### Cách 3: Firebase Hosting (Free, tốt)

```bash
# 1. Install Firebase CLI
npm i -g firebase-tools

# 2. Login
firebase login

# 3. Init (chọn Hosting)
firebase init

# 4. Build và deploy
flutter build web --release
firebase deploy
```

---

### Cách 4: GitHub Pages (Free, đơn giản)

```bash
# 1. Build web
flutter build web --release --base-href "/your-repo-name/"

# 2. Copy build/web vào gh-pages branch
# 3. Push lên GitHub
# 4. Enable GitHub Pages trong Settings
```

**URL:** `https://YOUR_USERNAME.github.io/your-repo-name/`

---

## ⚙️ Cấu hình Flutter Web

### File `web/index.html`

Đảm bảo có đúng cấu hình:

```html
<!DOCTYPE html>
<html>
  <head>
    <base href="$FLUTTER_BASE_HREF" />
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mac Store</title>
  </head>
  <body>
    <script>
      var serviceWorkerVersion = null;
      var FLUTTER_BASE_HREF = "/";
    </script>
    <!-- Flutter script -->
  </body>
</html>
```

### Build với base href cho subfolder

Nếu deploy vào subfolder (như GitHub Pages):

```bash
flutter build web --release --base-href "/mac-store-app/"
```

---

## 🔧 Lưu ý quan trọng khi deploy Web

### 1. API URL

Đảm bảo API backend đã deploy và có CORS cho phép web app:

```javascript
// Backend (Express.js)
app.use(
  cors({
    origin: ["https://your-web-app.vercel.app", "http://localhost"],
    credentials: true,
  })
);
```

### 2. Environment Variables

Có thể dùng khác nhau cho web và mobile:

```dart
// lib/config.dart
class AppConfig {
  static String get apiUrl {
    if (kIsWeb) {
      return 'https://api.yourdomain.com'; // Production API
    } else {
      return 'http://192.168.1.2:300'; // Local cho mobile
    }
  }
}
```

### 3. Responsive Design

Đảm bảo web app responsive trên mobile và desktop.

---

## 📝 Format trong CV

### Nếu có cả Web và APK:

```markdown
📱 Mac Store E-commerce App
Flutter | Node.js | MongoDB

Full-featured shopping app với authentication, cart, order management

🌐 Live Demo: https://mac-store.vercel.app
📥 APK: github.com/username/repo/releases
📂 Source: github.com/username/repo
🎬 Demo Video: [Link]

Tech: Flutter, Dart, Riverpod, Node.js, Express, MongoDB
```

### Nếu chỉ có Web:

```markdown
📱 Mac Store E-commerce App
Flutter Web | Node.js | MongoDB

🌐 Live: https://mac-store.vercel.app
📂 Code: github.com/username/repo
```

---

## ✅ Checklist Deploy Web

- [ ] Test app trên web local: `flutter run -d chrome`
- [ ] Update API URL cho production
- [ ] Test responsive (mobile/desktop)
- [ ] Build web: `flutter build web --release`
- [ ] Test build local: `cd build/web && python3 -m http.server`
- [ ] Deploy lên Vercel/Netlify
- [ ] Test trên production URL
- [ ] Kiểm tra API calls hoạt động
- [ ] Update link trong CV

---

## 🎯 Kết luận

**Cho CV: Deploy WEB là lựa chọn tốt nhất**

- Recruiter có thể xem ngay, không cần download
- Professional và dễ share
- Thể hiện được full-stack skills
- **Nên làm cả Web + APK** để showcase đầy đủ nhất

**Quick Start:**

```bash
# Build web
flutter build web --release

# Deploy với Vercel (nhanh nhất)
npm i -g vercel
cd build/web
vercel --prod
```
