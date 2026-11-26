# 🤝 ការណែនាំសម្រាប់ការធ្វើការជាក្រុម (Teamwork & Git Workflow)

សូមស្វាគមន៍មកកាន់គម្រោង **ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung Restaurant E-Commerce)**!  
ឯកសារនេះរៀបចំឡើងដើម្បីឱ្យក្រុមការងារ (Team Members) អាចសហការគ្នាបានយ៉ាងរលូន ដោយគ្មានជម្លោះកូដ (Merge Conflicts)។

---

## 🌿 ស្ថាបត្យកម្ម Branch (Clean Branching Strategy)

យើងប្រើប្រាស់ទម្រង់ **Git Flow Simplified**៖

1. **`main` (Production Branch):**
   - សម្រាប់តែកូដដែលបានតេស្ត និងដំណើរការ ១០០% គ្មាន Error គ្មាន Warning។
   - មិនអនុញ្ញាតឱ្យ Push ដោយផ្ទាល់ឡើយ (Protect `main`)។
2. **`develop` (Integration Branch):**
   - ជាមែកធាងមេសម្រាប់ការអភិវឌ្ឍរួមរបស់ក្រុម។
   - សមាជិកក្រុមត្រូវទាញ (Pull) និងបង្កើត Feature Branch ចេញពី `develop`។
3. **`feature/<name>` (Feature Branches):**
   - សម្រាប់មុខងារថ្មីៗ ឧទាហរណ៍៖
     - `feature/user-notifications`
     - `feature/table-reservation`
     - `feature/driver-tracking`
4. **`fix/<issue-name>` (Bugfix Branches):**
   - សម្រាប់ជួសជុលបញ្ហាដែលរកឃើញ ឧទាហរណ៍ `fix/khqr-timeout`។

---

## 🚀 របៀបចាប់ផ្តើមសម្រាប់សមាជិកក្រុមថ្មី (Getting Started)

### ១. Clone គម្រោងមកកាន់កុំព្យូទ័រ
```bash
git clone https://github.com/Vatana007/App-ECommerce-Flutter.git
cd App-ECommerce-Flutter
git checkout develop
```

### ២. ដំឡើង និងដំណើរការ Backend
Backend ចម្បងរបស់ប្រព័ន្ធស្ថិតនៅក្នុងគម្រោង `E-Restaurant/backend`:
```bash
cd "D:\DUC-Learning-All-Year\Year 4\React\Code\E-Restaurant\backend"
npm install
node server.js
```
> Backend នឹងដំណើរការលើ `http://127.0.0.1:5000`

### ៣. ដំឡើង និងដំណើរការ Flutter App
```bash
cd "D:\DUC-Learning-All-Year\Year 4\Flutter\Code\Project-Final\flutter_app"
flutter pub get
flutter run -d chrome
```

---

## 📝 របៀបធ្វើការលើ Feature ថ្មី (Daily Workflow)

### ជំហានទី ១: បង្កើត Feature Branch ចេញពី `develop`
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### ជំហានទី ២: ធ្វើតេស្ត និង Commit កូដតាមស្តង់ដារ Conventional Commits
```bash
# ពិនិត្យភាពត្រឹមត្រូវមុននឹង commit
cd flutter_app
flutter analyze

# ត្រឡប់មក Root folder
cd ..
git add .
git commit -m "feat(catalog): add dish dietary filter chips"
```

**ប្រភេទ Commit គំរូ:**
- `feat:` បន្ថែមមុខងារថ្មី
- `fix:` ជួសជុលបញ្ហា / bug
- `refactor:` កែលម្អរចនាសម្ព័ន្ធកូដដោយមិនប្តូរមុខងារ
- `style:` កែប្រែ UI / CSS / Theme
- `docs:` កែប្រែឯកសារ Documentation

### ជំហានទី ៣: Push និងបង្កើត Pull Request (PR)
```bash
git push -u origin feature/your-feature-name
```
- បើក GitHub រួចបង្កើត **Pull Request** ពី `feature/your-feature-name` ចូលទៅកាន់ `develop`។
- ឱ្យមិត្តរួមក្រុមជួយ Review រួច Merge ចូល `develop`។

---

## 🔒 ច្បាប់សុវត្ថិភាពសម្រាប់ក្រុម (Team Golden Rules)

1. **កុំ Commit `node_modules` ឬ `build/`:** `.gitignore` ត្រូវបានរៀបចំរួចរាល់ សូមកុំលុប ឬកែប្រែដោយគ្មានការពិភាក្សា។
2. **កុំ Commit ព័ត៌មានសម្ងាត់ (`.env`):** ប្រើ `.env.example` សម្រាប់ចែករំលែក Config Template។
3. **តែងតែ Run `flutter analyze` មុននឹង Commit:** ធានាថាគ្មាន Warning ឬ Error។
