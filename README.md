# VIT Smart Canteen System

A comprehensive digital canteen ordering ecosystem for VIT (Vellore Institute of Technology) campus, consisting of a student/staff mobile application and an admin web dashboard.

## 📦 Project Structure

This repository contains two Flutter applications:

```
Flutter project/
├── vbite/                      # Mobile app for students/staff
├── smart_canteen_admin/        # Web-based admin dashboard
└── README.md                   # This file
```

---

## 📱 VBite - Mobile App

**Directory**: `/vbite`

A feature-rich Flutter mobile application that enables students and staff to browse menus, place orders (individual and group), manage wallets, and track deliveries in real-time.

### Key Features

- 🔐 **Authentication**: Email/Password with VIT domain validation
- 🍽️ **Digital Menu**: Real-time menu browsing with categories and search
- 🛒 **Smart Cart**: Shopping cart with quantity management
- 👥 **Group Orders**: Collaborative ordering with shared carts
- 💰 **Wallet System**: Built-in wallet (max ₹1000) for seamless payments
- 📦 **Order Tracking**: Real-time order status updates
- ⭐ **Reviews & Ratings**: Feedback system for menu items
- 📱 **Multi-Platform**: Android, iOS, Web support

### Tech Stack

- **Framework**: Flutter 3.8.1+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter
- **Local Storage**: Hive, SharedPreferences
- **UI Components**: Material Design 3, Shimmer, Lottie

### Quick Start

```bash
cd vbite
flutter pub get
flutter run
```

**Note**: Requires Firebase configuration. See `/vbite/README.md` for detailed setup.

---

## 🖥️ Smart Canteen Admin - Web Dashboard

**Directory**: `/smart_canteen_admin`

A web-based admin panel for managing canteen operations, including menu management, order processing, analytics, and group order oversight.

### Key Features

- 📊 **Dashboard**: Overview with key metrics and analytics
- 🍕 **Menu Management**: Add, edit, and manage menu items
- 📦 **Order Management**: Track and update order statuses
- 👥 **Group Order Tracking**: Monitor collaborative orders
- 📈 **Reports & Analytics**: Sales reports and performance insights
- 🔐 **Admin Authentication**: Secure admin-only access

### Tech Stack

- **Framework**: Flutter 3.8.1+ (Web)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter
- **Charts**: fl_chart

### Quick Start

```bash
cd smart_canteen_admin
flutter pub get
flutter run -d chrome
```

**Note**: Requires Firebase configuration and admin credentials.

---

## 🗂️ Backend Infrastructure

**Directory**: `/vbite/backend`

Shared Firebase backend configuration and utilities.

### Components

- **Firestore Rules**: Security rules for data access
- **Firestore Indexes**: Query optimization indexes
- **Cloud Functions**: Server-side logic (Node.js)
- **Admin Scripts**: User management and data seeding
- **Menu Data**: Sample menu items with images

### Key Files

- `firestore.rules` - Security rules
- `firestore.indexes.json` - Database indexes
- `menu_items_with_images.json` - Menu data
- `create-admin-user.js` - Admin user creation script
- `firebase-setup.md` - Setup guide

---

## 🔥 Firebase Setup

Both applications share a Firebase project. Follow these steps:

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication, Firestore, and Storage

### 2. Configure Authentication

- Enable Email/Password authentication
- Add authorized domain (for web)

### 3. Setup Firestore

```bash
cd vbite/backend
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 4. Create Admin User

```bash
cd vbite/backend
node create-admin-user.js
```

Follow the prompts to create an admin account.

### 5. Seed Menu Data

Upload `menu_items_with_images.json` to Firestore using the Firebase console or provided scripts.

### 6. Configure Apps

- Update `firebase_options.dart` in both projects
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)

See `/vbite/backend/firebase-setup.md` for detailed instructions.

---

## 📊 Data Architecture

### Firestore Collections

```
users/                          # User profiles
  {userId}/
    - id, email, name, role
    - department, studentId
    - wallet info

menu/
  categories/{categoryId}/      # Menu categories
  items/{itemId}/              # Menu items
    - name, description, price
    - imageUrl, isAvailable
    - rating, reviewCount

orders/                         # Individual orders
  {orderId}/
    - userId, items[], totalAmount
    - paymentStatus, orderStatus
    - isGroupOrder, groupId

group_orders/                   # Group orders
  {groupId}/
    - name, joinCode, adminId
    - status, members[], cartItems[]

wallets/                        # User wallets
  {userId}/
    - balance (max ₹1000)
    - transactions/ (subcollection)

payments/                       # Payment records
reviews/                        # Item reviews
analytics/                      # Usage analytics
```

---

## 🚀 Development

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK (latest stable)
- Firebase CLI
- Node.js (for backend scripts)
- Android Studio / VS Code

### Running Both Apps

**Mobile App:**
```bash
cd vbite
flutter pub get
flutter run
```

**Admin Dashboard:**
```bash
cd smart_canteen_admin
flutter pub get
flutter run -d chrome
```

### Development Workflow

1. **Feature Development**: Work in feature branches
2. **Testing**: Run tests before committing
3. **Backend Changes**: Update Firestore rules and deploy
4. **Documentation**: Update relevant README files

---

## 📁 Project Documentation

### VBite App Documentation

- **README**: `/vbite/README.md` - Setup and features
- **Technical Details**: `/vbite/TECHNICAL_DETAILS.md` - Architecture deep dive
- **Stage Summaries**: `/vbite/STAGE_*_SUMMARY.md` - Development progress
- **Backend Setup**: `/vbite/backend/firebase-setup.md`

### Admin Dashboard Documentation

- **README**: `/smart_canteen_admin/README.md`
- **Progress Report**: `/smart_canteen_admin/PROGRESS_REPORT.md`

---

## 🎯 Project Status

### ✅ Completed Features

**VBite Mobile App:**
- ✅ Authentication system (Email/Password, VIT domain validation)
- ✅ Digital menu with categories and search
- ✅ Shopping cart functionality
- ✅ Individual order placement
- ✅ Group ordering system (collaborative carts)
- ✅ Wallet system with transaction history
- ✅ Order tracking and history
- ✅ Reviews and ratings
- ✅ Real-time updates via Firestore streams

**Admin Dashboard:**
- ✅ Admin authentication
- ✅ Dashboard with metrics
- ✅ Menu management (CRUD operations)
- ✅ Order management
- ✅ Group order monitoring
- ✅ Basic analytics and reports

### Code Style

- Follow Flutter/Dart style guidelines
- Use `flutter_lints` for code quality
- Write meaningful commit messages
- Document complex logic

## 👥 Team

- **Target Institution**: VIT (Vidyalankar Istitute of Technology)
- **Project Type**: Campus Canteen Management System
- **Development**: Student/Academic Project

---

## 📞 Support

For issues, questions, or contributions:

1. Check existing documentation in `/vbite` and `/smart_canteen_admin`
2. Review Firebase setup guide at `/vbite/backend/firebase-setup.md`
3. Create an issue in the repository
4. Contact the development team

---

## 🔗 Quick Links

- [VBite App README](vbite/README.md)
- [Admin Dashboard README](smart_canteen_admin/README.md)
- [Technical Documentation](vbite/TECHNICAL_DETAILS.md)
- [Backend Setup Guide](vbite/backend/firebase-setup.md)
- [Firebase Console](https://console.firebase.google.com/)

---

**Last Updated**: January 2026
