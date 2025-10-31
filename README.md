# Neighbourhood Watch Admin Application

A comprehensive Flutter-based admin dashboard for managing the Neighbourhood Watch security system. This application provides administrators with complete control over users, houses, security checkpoints, subscriptions, patrols, payments, and emergency alerts.

## 🚀 Features

### 🔐 Authentication & Authorization
- **Secure Login**: Role-based access control for administrators
- **Session Management**: Automatic user session handling
- **Role Enforcement**: Admin-only access with proper validation

### 👥 User Management
- **Complete User CRUD**: Create, read, update, and delete users
- **Role Assignment**: Assign ADMIN, OFFICER, or MEMBER roles
- **Status Management**: Approve, suspend, reinstate, block users
- **Advanced Filtering**: Search by name, email, phone, or role
- **Real-time Updates**: Live status changes and user management

### 🏠 House Management
- **Property Management**: Add, edit, and delete monitored houses
- **Location Tracking**: House locations and identification
- **Search & Filter**: Find houses by name, number, or location
- **Visual Organization**: Color-coded house cards for easy identification

### 🏠 House Member Management
- **Member Assignment**: Assign users to houses with relationships (Owner, Tenant, Family, Member)
- **Membership Lifecycle**: Active and ended membership tracking
- **Relationship Management**: Update member relationships
- **Soft & Hard Delete**: End memberships or permanently delete

### 📍 Checkpoint Management
- **Security Points**: Create and manage security checkpoints
- **House Association**: Link checkpoints to specific houses
- **Type Classification**: GATE, HOUSE, and PATROL checkpoint types
- **Code System**: Unique checkpoint codes for easy identification
- **Advanced Search**: Search by code, name, or location

### 📊 Subscriptions (View Only)
- **Member Subscriptions**: View all subscription records
- **Status Tracking**: Active, In Arrears, Expired, Cancelled statuses
- **Financial Overview**: Subscription types and payment tracking
- **Expiration Alerts**: Days remaining with color-coded warnings

### 🚔 Patrol Records (View Only)
- **Officer Activity**: View all patrol check-ins
- **Anomaly Detection**: Flagged incidents and normal checks
- **Location Tracking**: GPS coordinates and checkpoint information
- **Time-based Filtering**: Today, This Week, or All Time views

### 💳 Payment Transactions (View Only)
- **Payment History**: Complete transaction records
- **Method Tracking**: CASH, MOBILE_MONEY, BANK_TRANSFER, CARD
- **Financial Statistics**: Total revenue and average payments
- **Reference Tracking**: Transaction references and member links

### 🚨 SOS Alerts (View Only)
- **Emergency Management**: View all emergency alerts
- **Urgent Status**: Color-coded priority indicators (PENDING, RESOLVED)
- **Location Data**: GPS coordinates and checkpoint associations
- **Real-time Updates**: Time-based alert organization

## 🛠 Technical Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Built-in Flutter State Management
- **HTTP Client**: Dart http package
- **API Integration**: RESTful API consumption
- **UI Components**: Material Design 3
- **Platform Support**: iOS, Android, Web

## 📱 UI/UX Features

- **Responsive Design**: Optimized for mobile and desktop
- **Material Design**: Modern, intuitive interface
- **Color-Coded System**: Visual status indicators
- **Advanced Filtering**: Multi-criteria search and filtering
- **Real-time Updates**: Live data refresh capabilities
- **Loading States**: Smooth user experience with progress indicators
- **Error Handling**: Comprehensive error messages and validation

## 🏗 Architecture

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # Main app configuration
├── constants/
│   ├── app_constants.dart    # API URLs and constants
│   └── enums.dart           # Enums and helper functions
├── models/                   # Data models
│   ├── user.dart
│   ├── house.dart
│   ├── house_member.dart
│   ├── checkpoint.dart
│   ├── subscription.dart
│   ├── patrol.dart
│   ├── payment.dart
│   └── sos_alert.dart
├── services/                 # API service classes
│   ├── api_service.dart
│   ├── house_service.dart
│   ├── house_member_service.dart
│   ├── checkpoint_service.dart
│   ├── subscription_service.dart
│   ├── patrol_service.dart
│   ├── payment_service.dart
│   └── sos_service.dart
├── pages/                    # Screen components
│   ├── landing_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── admin_dashboard_page.dart
│   ├── user_management_page.dart
│   ├── house_management_page.dart
│   ├── house_member_management_page.dart
│   ├── checkpoint_management_page.dart
│   ├── subscriptions_page.dart
│   ├── patrols_page.dart
│   ├── payments_page.dart
│   └── sos_alerts_page.dart
└── widgets/                  # Reusable UI components
    └── neumorphic_surface.dart
```

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- Android Studio / VS Code with Flutter extension
- Backend API running on `http://localhost:8080`

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd neighbourhood-watch-admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Update `API_BASE_URL` in `lib/constants/app_constants.dart`
   - For Android emulator: `http://10.0.2.2:8080/api`
   - For physical device: Use your computer's IP address
   - For production: Your production API URL

4. **Run the application**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🎯 Usage Guide

### Getting Started
1. **Launch the application**
2. **Login with admin credentials**
3. **Access the dashboard** with all management tools
4. **Navigate** to specific management sections as needed

### Key Operations

#### User Management
- Create new users with specific roles
- Approve pending member registrations
- Suspend or block problematic users
- Reinstate previously suspended users

#### House & Member Management
- Add new houses to the monitoring system
- Assign members to houses with appropriate relationships
- Update member relationships as needed
- End memberships when residents move out

#### Security Management
- Set up security checkpoints throughout the neighbourhood
- Link checkpoints to specific houses for targeted monitoring
- Monitor patrol activities and officer check-ins
- Respond to emergency SOS alerts

#### Financial Management
- View subscription status and payment history
- Monitor revenue and transaction patterns
- Track expired subscriptions and payment arrears

## 🔐 Security Features

- **Role-based Access Control**: Admin-only functionality
- **Input Validation**: Comprehensive form validation
- **API Security**: Proper authentication token handling
- **Data Protection**: Secure data transmission
- **Session Management**: Automatic logout and session clearing

## 📊 Monitoring & Analytics

The admin dashboard provides:
- Real-time statistics for each module
- Visual status indicators
- Quick overview cards with key metrics
- Filterable data views for detailed analysis
- Export-ready data presentation

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Verify the backend server is running
   - Check `API_BASE_URL` configuration
   - Ensure proper network connectivity

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Ensure Flutter SDK is up to date
   - Check Dart version compatibility

3. **Login Issues**
   - Verify admin credentials
   - Check user role is set to ADMIN
   - Ensure backend user service is operational

### Debug Mode
Enable debug mode for detailed logging:
```bash
flutter run --debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the troubleshooting section above
- Review API documentation
- Contact the development team
- Create an issue in the repository

## 🔄 Updates & Maintenance

- Regular security updates
- Feature enhancements based on user feedback
- Performance optimizations
- Compatibility updates with Flutter releases

---

**Built with ❤️ for community safety and security management**
