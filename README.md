# 🍲 ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung Restaurant) - Full E-Commerce Platform

A production-ready Full Stack Food & Restaurant E-Commerce application with:
- **Client App / Web**: Flutter 3 (Riverpod 3.5, GoRouter, Dio, Kantumruy Pro Typography) - Runs seamlessly on **Web Browser (Chrome/Edge)**, **Android**, **iOS**, and **Desktop**.
- **Live Cloud Backend API**: Hosted on Render (`https://e-restaurant-uk4w.onrender.com/api`) connected to MongoDB Atlas, supporting online orders, customer auth, and authentic food menu images.
- **Central Local Backend (Optional)**: Node.js Express REST API in `D:\DUC-Learning-All-Year\Year 4\React\Code\E-Restaurant\backend`.
- **Authentic Payment**: **Real NBC Bakong KHQR** (`bakong-khqr`) EMVCo standard generation, real-time transaction verification via MD5.
- **GitHub Repository**: [https://github.com/Vatana007/App-ECommerce-Flutter.git](https://github.com/Vatana007/App-ECommerce-Flutter.git)

---

## 🏗️ ស្ថាបត្យកម្មប្រព័ន្ធ (System Architecture)

```text
Project-Final/
├── flutter_app/                # Flutter Client (Mobile + Web E-Commerce)
│   ├── lib/
│   │   ├── main.dart           # App Entrypoint with ProviderScope
│   │   ├── app/
│   │   │   ├── app.dart        # MaterialApp.router & Localization
│   │   │   └── router/         # GoRouter with full navigation routes
│   │   ├── core/
│   │   │   ├── config/         # AppConfig (auto-detects Web, Android, Windows to Port 5000)
│   │   │   ├── network/        # DioClient with Auth & Logging interceptors
│   │   │   └── theme/          # Authentic Cambodian typography & AppTheme
│   │   ├── features/
│   │   │   ├── catalog/        # Categories selector, search, 160 dishes repository
│   │   │   ├── cart/           # Cart provider, quantity update, coupon discounts
│   │   │   ├── checkout/       # Delivery details, payment method selector
│   │   │   ├── scan/           # QR code & food code scanner
│   │   │   ├── wishlist/       # Saved favorite dishes
│   │   │   ├── orders/         # Order tracking timeline & order history
│   │   │   ├── product_detail/ # Dish details, spice levels, add to cart
│   │   │   ├── profile/        # Customer profile & Admin portal trigger
│   │   │   ├── admin/          # All-in-One Admin Management Portal
│   │   │   └── home/           # Restaurant announcement, promo banners, categories
│   │   └── shared/
│   │       ├── models/money.dart # Dual currency (USD $ & KHR ៛ at 4,100 rate)
│   │       └── widgets/        # Modern minimal BottomNavigationBar, ProductCard
│   ├── build/web/              # Pre-compiled high performance Web Application
│   └── pubspec.yaml
│
└── 🌐 Backend Service:
    └── E-Restaurant/backend/   # Single Master API Server (Port 5000)
        ├── routes/v1Routes.js  # Unified API endpoints for Flutter & Web (/api/v1/...)
        ├── data/dishes.json    # 160 Authentic Cambodian dishes & category mapping
        └── server.js           # Central Express API with Bakong KHQR & MongoDB
```

---

## ⚡ របៀបដំណើរការ (How to Run)

### ១. ដំណើរការ Backend (Node.js Express API)
បើក Terminal ទីមួយ ហើយចូលទៅកាន់ folder `E-Restaurant/backend`:
```bash
cd "D:\DUC-Learning-All-Year\Year 4\React\Code\E-Restaurant\backend"
node server.js
```
> API Server នឹងដំណើរការលើ: `http://127.0.0.1:5000`
> - **Categories:** `http://127.0.0.1:5000/api/v1/categories`
> - **Dishes (160 items):** `http://127.0.0.1:5000/api/v1/products`
> - **Settings:** `http://127.0.0.1:5000/api/v1/settings`
> - **Orders:** `http://127.0.0.1:5000/api/v1/orders`

---

### ២. ដំណើរការ Frontend (Flutter App & Web)

#### ជម្រើស A: បើកលើ Web Browser (Chrome)
បើក Terminal ទីពីរ ហើយចូលទៅកាន់ folder `flutter_app`:
```bash
cd "flutter_app"
flutter run -d chrome
```

#### ជម្រើស B: បើកលើ Android Emulator
```bash
flutter run -d android
```
*(AppConfig នឹងប្តូរ Base URL ស្វ័យប្រវត្តទៅ `http://10.0.2.2:5000/api/v1` សម្រាប់ Android Emulator)*

#### ជម្រើស C: បើកលើ Windows Desktop
```bash
flutter run -d windows
```

---

## 💳 ការទូទាត់តាម Bakong KHQR (Real KHQR Features)

1. **EMVCo Compliant String:** 
   - គណនា Tag 00 ដល់ Tag 99 តាមស្តង់ដារធនាគារជាតិនៃកម្ពុជា (NBC)។
   - គណនា CRC16-CCITT (Checksum 4 ខ្ទង់) ត្រឹមត្រូវ ១០០% ផ្គូផ្គងនឹងបណ្ណាល័យផ្លូវការ `bakong-khqr`។
2. **MD5 Transaction Hash:**
   - បង្កើត MD5 hash នៃ KHQR string សម្រាប់ផ្ទៀងផ្ទាត់លើ API NBC Bakong (`https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5`)។
3. **ប៊ូតុងត្រួតពិនិត្យ ២ ជម្រើស (Two Verification Buttons):**
   - **ពិនិត្យដោយដៃ (Manual Check):** ចុចដើម្បីផ្ទៀងផ្ទាត់ភ្លាមៗតាមតម្រូវការរបស់អ្នកប្រើប្រាស់។
   - **ពិនិត្យស្វ័យប្រវត្តិ (Auto-Check: OFF/ON):** អាចបិទ/បើកការត្រួតពិនិត្យស្វ័យប្រវត្តបានតាមចិត្ត។

---

## 👑 ប្រព័ន្ធគ្រប់គ្រងរួមតែមួយ (All-in-One Admin & Customer App)

កម្មវិធីនេះត្រូវបានរៀបចំជា **All-in-One** ដោយបញ្ចូលទាំងផ្នែកអតិថិជន និងផ្នែកគ្រប់គ្រង (Admin Portal) ក្នុង Flutter App តែមួយ៖

- **គណនី Admin សាកល្បង:**
  - **Email:** `admin@phumyeung.com`
  - **Password:** `admin123`
- **របៀបចូល Admin:**
  1. ចូលទៅកាន់ Tab **"គណនី (Account / Profile)"** នៅលើ Bottom Navigation Bar។
  2. ចុចលើផ្ទាំង **"ផ្ទាំងគ្រប់គ្រងហាង (Admin Management Portal)"**។
  3. បញ្ចូល Email & Password (ឬចុចប៊ូតុង "បំពេញស្វ័យប្រវត្តិ Demo Admin") រួចចុចចូល។
- **មុខងារសំខាន់ៗរបស់ Admin:**
  - 📊 **ផ្ទាំងស្ថិតិ (Dashboard Overview):** មើលចំណូលសរុប ចំនួនការកុម្ម៉ង់ កំពុងរង់ចាំ និងចំនួនមុខម្ហូប។
  - 📋 **គ្រប់គ្រងការកុម្ម៉ង់ផ្ទាល់ (Live Order Management):** តម្រៀបតាមផ្ទាំង `pending`, `preparing`, `delivering`, `delivered` និងប្តូរស្ថានភាព Order ដោយចុចតែ ១ ប៊ូតុង។
  - 🍲 **គ្រប់គ្រងមុខម្ហូប & តម្លៃ (Dishes Catalog & Prices):** ស្វែងរកមុខម្ហូបទាំង ១៦០ មុខ កែប្រែតម្លៃ ប្តូរកម្រិតហិរ និងដាក់ក្នុងមុខម្ហូបពិសេស (Featured)។
  - ⚙️ **ការកំណត់ហាង (Store Settings):** បិទ/បើកហាងផ្ទាល់ កំណត់ថ្លៃសេវាដឹកជញ្ជូន កំណត់អត្រាប្តូរប្រាក់រៀល (KHR Exchange Rate) និងសរសេរសារជូនដំណឹង (Announcement Banner)។

---

## 🎁 កូដប្រូម៉ូសិន (Available Promo Codes)

| កូដ (Promo Code) | ការបញ្ចុះតម្លៃ | លក្ខខណ្ឌ |
|---|---|---|
| `PHUM10` | បញ្ចុះតម្លៃ **10%** | សម្រាប់ការកុម្ម៉ង់ដំបូង |
| `KHMER20` | បញ្ចុះតម្លៃ **20%** | សម្រាប់ការកុម្ម៉ង់លើសពី $20 |
| `FREESHIP` | មិនគិតថ្លៃដឹក **$1.50** | ដឹកជញ្ជូនឥតគិតថ្លៃ |
