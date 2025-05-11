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
git clone https://github.com/elechacked/salesmate.git
cd salesmate-flutter
flutter pub get
flutter run


🧪 Testing
Widget tests: Coming soon

Integration tests: Planned for critical modules

🧾 Future Roadmap
 Employee offline mode & sync queue

 Company-wide insights & heatmaps

 Export to PDF reports

 Admin alerts & reminders

 Support ticket management

 Flutter Web compatibility

🤝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.

📜 License
This project is licensed under the MIT License.

💼 Built By
Aryan – B.Tech Student at KCC Institute of Technology and Management
Passionate Flutter Developer | App Architect | Backend Integrator

📸 Screenshots (Coming Soon)
Want to help design beautiful screenshots or a logo? Open a PR!

📬 Contact
For issues, reach out via GitHub issues or email [elec.hacked@gmail.com]

yaml
Copy
Edit

---

Would you like a logo, banner, or contribution guidelines added to this README as well?
