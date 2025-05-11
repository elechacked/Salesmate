# 🚀 SalesMate – Smart Sales Visit Tracking App

SalesMate is a robust, multi-role field sales tracking solution built with **Flutter** and backed by **Firebase** (initially) and now transitioning to a **self-hosted backend** (Apache2 + PHP + MySQL). It enables companies to monitor, manage, and evaluate field sales visits with accuracy, accountability, and real-time insights.

---

## 📱 Platform

- **Mobile App**: Built with Flutter 3.x
- **Backend**: Currently only doing with firebase
Using Firebase Authentication , Firestore , Firestore Database.

---

## 🎯 Core Use Case

SalesMate digitizes sales visit logs, enabling sales reps to check in with selfie and location, while managers gain full visibility on daily activities, employee performance, and historical visit data — all in real-time.

---

## 🧠 Features Overview

### 👤 Employee Module
- Role-based login (Firebase Auth / Custom Auth)
- View assigned, ongoing, and completed visits
- Secure **Check-In/Check-Out** flow with:
  - Capture GPS location (via Google Maps API)
  - Time synced with NTP server
  - Selfie capture & upload
- Add remarks during checkout
- Limited profile editing (photo only)
- Export visit data to CSV/Excel
- (Planned) Offline mode + data caching

### 🏢 Company Admin Module
- Role-based login
- Create & manage employee accounts
- Assign visits and monitor visit statuses
- View visit analytics & employee metrics
- Company profile management
- Export reports
- (Future) Support ticket system

### 🛡️ Super Admin Module
- Create/manage companies (Admin accounts)
- Configure:
  - Max employee limit per company
  - Account expiry duration (e.g., 1 year)
- Lockout expired company access
- System-wide analytics and audit logs

---


---

## 🛠️ Setup Instructions

### 🚧 Prerequisites

- Flutter SDK 3.x
- Dart SDK
- Git
- Firebase CLI (if using Firebase backend)

### 🔧 Flutter Setup

```bash
git clone https://github.com/YOUR_USERNAME/salesmate-flutter.git
cd salesmate-flutter
flutter pub get
flutter run


