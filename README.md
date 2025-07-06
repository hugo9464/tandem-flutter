# Tandem Flutter App

A Flutter implementation of the Tandem PWA banking application using mocked data.

## Features

- View bank accounts with balances
- Browse transactions with filtering capabilities
- Filter by date range, transaction type, status, and search
- Responsive design with Material 3
- Bottom navigation for easy access to different sections
- Offline status indicator

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the build runner to generate JSON serialization code:
   ```bash
   flutter pub run build_runner build
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   ├── account.dart
│   └── transaction.dart
├── screens/                  # UI screens
│   ├── home_screen.dart     # Account listing
│   ├── transactions_screen.dart  # Transaction history
│   ├── about_screen.dart    # About page
│   └── contact_screen.dart  # Contact information
├── services/                 # Business logic
│   └── mock_data_service.dart  # Mock data generation
└── widgets/                  # Reusable widgets
    └── network_status.dart  # Network status indicator
```

## Mock Data

The app uses a `MockDataService` that generates:
- 3 sample bank accounts (Checking, Savings, Business)
- 50 transactions per account with various statuses and types
- Realistic transaction descriptions and metadata

## Future Enhancements

- Integration with Supabase for real data
- State management (Provider/Riverpod/Bloc)
- User authentication
- Transaction details screen
- Account settings
- Push notifications
- Biometric authentication