# Smart Canteen Admin - Web Dashboard

A comprehensive web-based admin panel for managing VIT Smart Canteen operations. Built with Flutter Web and Firebase, this dashboard provides real-time oversight of menu management, order processing, group orders, and analytics.

## 🌟 Features

### 🔐 Admin Authentication
- Secure email/password authentication for admin users
- Role-based access control
- Session management
- Admin-only access restrictions

### 📊 Dashboard Overview
- Real-time metrics and statistics
- Total orders, revenue, and active users
- Today's orders summary
- Quick access to key operations
- Visual charts and graphs (fl_chart)

### 🍕 Menu Management
- **Create/Edit Menu Items**: Add new items with details
- **Category Management**: Organize items into categories
- **Image Upload**: Upload and manage item images via Firebase Storage
- **Availability Control**: Toggle item availability in real-time
- **Pricing Management**: Update prices and item details
- **Ingredient Management**: Track ingredients for each item
- **Rating Display**: View customer ratings and reviews

### 📦 Order Management
- **Real-time Order Tracking**: View all active orders
- **Order Status Updates**: Change status (Pending → Preparing → Ready → Completed)
- **Order Details**: View complete order information
- **Payment Status**: Monitor payment confirmations
- **Order History**: Filter and search past orders
- **Order Timeline**: Track order progression
- **Customer Information**: View order placed by which user

### 👥 Group Order Management
- **Active Group Monitoring**: Track all active group orders
- **Member Lists**: View participants in each group
- **Cart Items**: See consolidated group cart items
- **Join Codes**: Access group join codes
- **Group Status**: Monitor group order states (Active → Ordering → Completed)
- **Admin Controls**: Manage group orders centrally

### 📈 Reports & Analytics
- **Sales Reports**: Daily, weekly, monthly revenue reports
- **Popular Items**: Track best-selling menu items
- **Order Analytics**: Order trends and patterns
- **User Statistics**: Active users and engagement metrics
- **Revenue Charts**: Visual representation of sales data
- **Performance Metrics**: System performance indicators

### 🛠️ Additional Features
- **Real-time Updates**: Firestore streams for live data
- **Responsive Design**: Works on desktop, tablet, and mobile browsers
- **Search & Filter**: Find orders, items, and users quickly
- **Export Data**: Export reports and analytics
- **Notifications**: Order status notifications
- **Audit Logs**: Track admin actions (planned)

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/           # App constants and configurations
│   ├── services/            # Firebase and business logic services
│   └── theme/              # Admin dashboard theme
│
├── features/
│   ├── auth/               # Admin authentication
│   │   └── screens/
│   │       └── login_screen.dart
│   │
│   ├── dashboard/          # Main dashboard
│   │   └── screens/
│   │       └── dashboard_screen.dart
│   │
│   ├── menu/               # Menu management
│   │   └── screens/
│   │       ├── menu_list_screen.dart
│   │       └── menu_item_form_screen.dart
│   │
│   ├── orders/             # Order management
│   │   └── screens/
│   │       ├── orders_list_screen.dart
│   │       └── order_details_screen.dart
│   │
│   ├── group_orders/       # Group order management
│   │   └── screens/
│   │       └── group_orders_screen.dart
│   │
│   └── reports/            # Analytics and reports
│       └── screens/
│           └── reports_screen.dart
│
└── shared/
    ├── models/             # Shared data models
    ├── providers/          # State management
    └── widgets/            # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Chrome browser (for development)
- Firebase project configured (shared with VBite app)
- Admin user credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_canteen_admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   This project shares Firebase configuration with the VBite mobile app.
   
   - Ensure Firebase project is set up (see `/vbite/backend/firebase-setup.md`)
   - Update `lib/firebase_options.dart` with your Firebase configuration
   - Ensure Firestore rules allow admin access

4. **Create Admin User**
   
   Use the admin creation script in the backend folder:
   ```bash
   cd ../vbite/backend
   node create-admin-user.js
   ```
   
   Follow the prompts to create an admin account with role `admin`.

5. **Run the application**
   ```bash
   flutter run -d chrome
   ```
   
   Or for production build:
   ```bash
   flutter build web
   ```

### Admin Credentials

After creating an admin user, you can log in with:
- **Email**: Your admin email (e.g., `admin@vit.edu.in`)
- **Password**: Set during admin creation

See `/vbite/backend/ADMIN_CREDENTIALS.txt` for credential management.

## 🔥 Firebase Configuration

### Required Services
- **Firebase Authentication**: Admin user authentication
- **Cloud Firestore**: Real-time database for all operations
- **Firebase Storage**: Image storage for menu items

### Firestore Collections Used

```
users/                      # User profiles (admin check via role field)
menu/
  categories/              # Menu categories
  items/                   # Menu items (read/write access for admin)
orders/                    # All orders (admin full access)
group_orders/              # Group orders (admin oversight)
wallets/                   # User wallets (read-only for admin)
payments/                  # Payment records
reviews/                   # Item reviews
analytics/                 # Usage analytics and metrics
```

### Security Rules

Ensure Firestore rules allow admin access:
```javascript
match /menu/{document=**} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

match /orders/{document=**} {
  allow read, write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

See `/vbite/backend/firestore.rules` for complete security rules.

## 🛠️ Technologies Used

### Frontend
- **Flutter SDK**: 3.8.1+ (Web)
- **Dart**: Latest stable
- **Material Design 3**: UI framework

### Backend & Services
- **Firebase Core**: 3.6.0
- **Firebase Auth**: 5.3.1 (Admin authentication)
- **Cloud Firestore**: 5.4.3 (Real-time database)
- **Firebase Storage**: 12.3.2 (Image storage)

### State Management & Navigation
- **Provider**: 6.1.2 (State management)
- **GoRouter**: 14.2.7 (Web routing with URL navigation)

### UI & Charts
- **fl_chart**: 0.69.0 (Charts and graphs)
- **Intl**: 0.19.0 (Date formatting, currency)

### Development Tools
- **Flutter Lints**: 5.0.0 (Code quality)

## 📊 Dashboard Features in Detail

### Main Dashboard
- **Key Metrics Cards**: Total orders, revenue, active users, pending orders
- **Recent Orders**: Latest order list with quick actions
- **Revenue Chart**: Weekly/monthly revenue visualization
- **Popular Items**: Top-selling menu items
- **Quick Actions**: Navigate to key sections

### Menu Management
- **Item List**: Paginated menu items with search
- **Add Item**: Form to create new menu items
- **Edit Item**: Update existing items
- **Delete Item**: Remove items (with confirmation)
- **Category Filter**: Filter by category
- **Availability Toggle**: Quick enable/disable items
- **Image Management**: Upload and update images

### Order Management
- **Order List**: All orders with filters (Active/Completed/Cancelled)
- **Order Details**: Complete order information
- **Status Updates**: Update order status with timestamps
- **Payment Verification**: Confirm payment status
- **User Info**: Customer details for each order
- **Order Search**: Search by order ID, user name, etc.

### Group Order Management
- **Active Groups**: List of all active group orders
- **Group Details**: Members, items, total amount
- **Join Codes**: View and share group join codes
- **Status Tracking**: Monitor group order progression
- **Manual Intervention**: Admin controls for group management

### Analytics & Reports
- **Date Range Filters**: Custom date range reports
- **Sales Reports**: Revenue breakdown by time period
- **Item Performance**: Best and worst performing items
- **User Analytics**: Registration trends, active users
- **Export Options**: Download reports as CSV/PDF (planned)

## 🔄 Development Workflow

### Running in Development
```bash
flutter run -d chrome --web-renderer html
```

### Building for Production
```bash
flutter build web --release
```

### Deployment

**Firebase Hosting** (Recommended):
```bash
cd smart_canteen_admin
flutter build web
firebase init hosting  # First time only
firebase deploy --only hosting
```

**Other Hosting Options**:
- Netlify
- Vercel
- GitHub Pages
- Any static hosting service

## 🧪 Testing

```bash
flutter test
```

## 📖 Documentation

- **README.md**: This file - Setup and overview
- **PROGRESS_REPORT.md**: Development progress tracker
- **Backend Setup**: `/vbite/backend/firebase-setup.md`
- **Admin Creation**: `/vbite/backend/CREATE_ADMIN_INSTRUCTIONS.md`

## 🎯 Project Status

### ✅ Completed
- Admin authentication
- Dashboard with key metrics
- Menu management (CRUD operations)
- Order list and details
- Group order monitoring
- Basic analytics
- Real-time updates

### 🔄 In Progress
- Advanced analytics dashboard
- Export functionality
- Audit logs

### 📋 Planned
- Staff management
- Inventory tracking
- Push notification management
- Advanced reporting
- Batch operations
- User management interface

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AdminFeature`)
3. Follow Flutter web best practices
4. Test on multiple browsers
5. Create a Pull Request

### Code Guidelines
- Follow Flutter/Dart style guide
- Use responsive design patterns
- Test on Chrome, Firefox, Safari, Edge
- Optimize for web performance
- Use semantic HTML elements

## 🔗 Related Projects

- **VBite Mobile App**: Student/staff mobile application (`../vbite`)
- **Backend Infrastructure**: Firebase configuration (`../vbite/backend`)

## 📞 Support

For admin panel issues:
1. Check `PROGRESS_REPORT.md` for known issues
2. Review Firebase console for backend errors
3. Verify admin user role in Firestore
4. Contact development team

## 🔐 Security Considerations

- Admin credentials should be securely stored
- Use HTTPS for production deployment
- Enable Firebase App Check for production
- Regular security audits
- Monitor admin action logs
- Implement IP whitelisting if needed

---

**Version**: 1.0.0+1  
**Flutter SDK**: 3.8.1+  
**Platform**: Web  
**Last Updated**: January 2026
