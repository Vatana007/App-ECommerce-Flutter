# 🤝 ការណែនាំសម្រាប់ការធ្វើការជាក្រុម (Teamwork & Git Workflow)

សូមស្វាគមន៍មកកាន់គម្រោង **ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung Restaurant E-Commerce)**!  
ឯកសារនេះរៀបចំឡើងដើម្បីឱ្យក្រុមការងារទាំងអស់អាចសហការគ្នាបានយ៉ាងរលូន រហ័ស និងគ្មានជម្លោះកូដ (Merge Conflicts)។

---

## 👥 សមាជិកក្រុមការងារ (Development Team)

គម្រោងនេះត្រូវបានរួមគ្នាអភិវឌ្ឍដោយក្រុមការងារនិស្សិតឆ្នាំទី ៤៖

1. **HIM Lihour**
2. **VUTH Vatana**
3. **LORN Sovannarorth**
4. **REAM Rithy**

---

## 🌿 ស្ថាបត្យកម្ម Branch (Clean Branching Strategy)

យើងប្រើប្រាស់ទម្រង់ **Git Flow Simplified**៖

1. **`main` (Production Branch):**
   - សម្រាប់តែកូដផ្លូវការដែលបានតេស្ត និងដំណើរការ ១០០% គ្មាន Error គ្មាន Warning។
   - មិនអនុញ្ញាតឱ្យ Push ដោយផ្ទាល់ឡើយ (Protect `main`)។
2. **`develop` (Integration Branch):**
   - ជាមែកធាងមេសម្រាប់ការអភិវឌ្ឍរួមរបស់ក្រុម។
   - សមាជិកក្រុមទាំងអស់ត្រូវទាញ (Pull) និងបង្កើត Feature Branch ចេញពី `develop`។
3. **`feature/<name>` (Feature Branches):**
   - សម្រាប់មុខងារថ្មីៗ ឧទាហរណ៍៖
     - `feature/user-notifications`
     - `feature/table-reservation`
     - `feature/order-history`
4. **`fix/<issue-name>` (Bugfix Branches):**
   - សម្រាប់ជួសជុលបញ្ហាដែលរកឃើញ ឧទាហរណ៍ `fix/khqr-timeout`។

---

## 🚀 របៀបចាប់ផ្តើមសម្រាប់សមាជិកក្រុមថ្មី (Getting Started)

> [!TIP]
> **Zero-Config Plug & Play:** កម្មវិធី Flutter ត្រូវបានភ្ជាប់ដោយផ្ទាល់ជាមួយ **Live Cloud Backend API** លើ Render (`https://e-restaurant-uk4w.onrender.com/api`) និង MongoDB Atlas រួចជាស្រេច។  
> សមាជិកក្រុមថ្មី**មិនចាំបាច់ដំឡើង ឬដំណើរការ Node.js Server លើកុំព្យូទ័រឡើយ**!

### ជំហានទី ១: Clone គម្រោងមកកាន់កុំព្យូទ័រ
បើក Terminal ឬ Git Bash រួចវាយបញ្ជា៖
```bash
git clone https://github.com/Vatana007/App-ECommerce-Flutter.git
cd App-ECommerce-Flutter
git checkout develop
```

### ជំហានទី ២: ដំឡើង Dependencies របស់ Flutter
```bash
cd flutter_app
flutter pub get
```

### ជំហានទី ៣: ដំណើរការ Flutter App
អ្នកអាចដំណើរការលើ Platform ណាមួយក៏បានតាមការចង់បាន៖

#### ជម្រើស A: ដំណើរការលើ Web Browser (Chrome - ណែនាំសម្រាប់ការតេស្តលឿន)
```bash
flutter run -d chrome
```

#### ជម្រើស B: ដំណើរការលើ Android Emulator ឬទូរស័ព្ទពិត
```bash
flutter run -d android
```

#### ជម្រើស C: ដំណើរការលើ Windows Desktop
```bash
flutter run -d windows
```

> [!NOTE]
> ពេលកម្មវិធីបើកដំណើរការ មុខម្ហូបពិតប្រាកដចំនួន ៥៩ មុខ ប្រភេទម្ហូប និងរូបភាពច្បាស់ៗពី Cloud នឹងបង្ហាញឡើងមកភ្លាមៗ!

---

## 📝 របៀបធ្វើការលើ Feature ថ្មី (Daily Workflow)

### ជំហានទី ១: ទាញយកកូដចុងក្រោយ និងបង្កើត Feature Branch ចេញពី `develop`
```bash
# ត្រឡប់មក develop រួចទាញកូដថ្មីៗពី GitHub
git checkout develop
git pull origin develop

# បង្កើត branch ថ្មីសម្រាប់មុខងាររបស់អ្នក
git checkout -b feature/your-feature-name
```

### ជំហានទី ២: សរសេរកូដ និងពិនិត្យគុណភាព (Quality Check)
មុននឹងធ្វើការ Commit សូមរត់ពាក្យបញ្ជាដើម្បីប្រាកដថាគ្មាន Error៖
```bash
flutter analyze
```
> ប្រសិនបើ `flutter analyze` បង្ហាញ **"No issues found!"** អ្នកអាចបន្តទៅជំហាន Commit បាន។

### ជំហានទី ៣: Commit កូដតាមស្តង់ដារ Conventional Commits
```bash
git add .
git commit -m "feat(orders): add order status tracking timeline"
```

**ប្រភេទ Commit គំរូ:**
- `feat:` បន្ថែមមុខងារថ្មី (New Feature)
- `fix:` ជួសជុលបញ្ហា (Bugfix)
- `refactor:` កែលម្អរចនាសម្ព័ន្ធកូដដោយមិនផ្លាស់ប្តូរមុខងារ
- `style:` កែប្រែ UI / ពណ៌ / Theme / Spacing
- `docs:` កែប្រែឯកសារ Documentation

### ជំហានទី ៤: Push ឡើង GitHub និងបង្កើត Pull Request (PR)
```bash
git push -u origin feature/your-feature-name
```
1. ចូលទៅកាន់ GitHub: [https://github.com/Vatana007/App-ECommerce-Flutter](https://github.com/Vatana007/App-ECommerce-Flutter)
2. ចុចប៊ូតុង **"Compare & pull request"**
3. ជ្រើសរើស Base branch: **`develop`** (មិនមែន `main` ទេ)
4. ផ្ញើ Link PR ទៅកាន់មិត្តរួមក្រុមដើម្បីពិនិត្យ (Review) និងចុច Merge។

---

## 🔒 ច្បាប់សុវត្ថិភាពសម្រាប់ក្រុម (Team Golden Rules)

1. **មិនត្រូវ Push ផ្ទាល់ទៅកាន់ `main` ឬ `develop` ឡើយ:** ត្រូវឆ្លងកាត់ `feature/<name>` និង Pull Request ជានិច្ច។
2. **កុំ Commit Files ធ្ងន់ៗ ឬ Cache:** ឯកសារដូចជា `build/`, `.dart_tool/`, `.idea/`, `.vscode/` ត្រូវបាន Ignore ក្នុង `.gitignore` រួចរាល់ហើយ សូមកុំលុបចេញពី `.gitignore`។
3. **តែងតែ Run `flutter analyze` មុននឹង Commit:** ដើម្បីធានាថាកូដដែល Push ទៅគ្មាន Warning ឬ Error ដែលនាំឱ្យប៉ះពាល់ដល់អ្នកដទៃ។
4. **ទាញកូដ (`git pull origin develop`) មុននឹងចាប់ផ្តើមការងាររាល់ថ្ងៃ:** ដើម្បីកាត់បន្ថយ Merge Conflict។
