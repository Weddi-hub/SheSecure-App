SheSecure - Women Safety Application 

🛡️SheSecure is a modern, cross-platform mobile application designed to empower women with real-time safety tools and seamless hardware integration. The app connects to a dedicated SheSecure hardware device via Bluetooth to provide instantaneous SOS alerts, location tracking, and remote monitoring.

🚀 Key Features

📡 Hardware Integration
•Bluetooth Connectivity: Seamlessly pair and connect with SheSecure hardware devices.
•Live Feedback: A dedicated hardware status panel provides real-time feedback from the connected device.
•Remote Commands:  
◦STATUS: Check if the device is active and healthy.
◦GPS Tracking: Fetch the hardware's exact coordinates and view them on a live map.
◦SOS Alert: Instantaneously trigger an emergency vibration on the hardware.
◦Remote Recording: Start a 10-second audio recording on the hardware, with the ability to "listen back" through the app.
◦Vibration: Trigger a manual vibration for testing or localized alerts.

🗺️ Real-time Safety Map
•Dual Tracking: View both your current location and your SheSecure hardware's location simultaneously.
•OpenStreetMap Integration: Interactive map with zoom controls and "follow-me" functionality.
•Coordinate Display: Precise latitude and longitude display for both user and device.

🔐 Security & User Management :
•Firebase Authentication: Secure Login and Sign-Up flows.
•Profile Management: Editable user profiles with real-time synchronization to Firestore.
•Password Reset: In-app request system for secure password recovery.
•Account Deletion: Full data privacy compliance—users can permanently delete their account and associated data.

🎨 Personalization & UI :
•Dynamic Theming: A global theme engine allowing users to switch the entire app's color scheme from Royal Purple to Safety Blue.
•Adaptive Design: All UI elements (App bars, icons, buttons, checkboxes) adapt instantly to the selected theme.
•Modern Widgets: Custom text fields, animated status bars, and glassmorphic panels for a premium user experience.

🛠️ Tech Stack
•Framework: Flutter
•Backend: Firebase (Auth & Firestore)
•State Management: Provider
•Bluetooth: Flutter Bluetooth Serial
•Maps: Flutter Map & Geolocator
•Database: Cloud Firestore for activity logs, SOS alerts, and user metadata.

📂 Project Structure

lib/
├── models/         # User and Device data models

├── screens/        # Auth, Home, Admin, and Splash screens

├── services/       # Bluetooth, Firebase, and Theme logic

├── utils/          # Validators and Global Theme definitions

└── widgets/        # Reusable UI components (Drawer, Popups, Command Panels)


⚙️ Setup & Installation
1.Clone the repository :
    git clone https://github.com/yourusername/she_secure.git
2.Install dependencies:
    flutter pub get

3.Firebase Setup:
◦Create a Firebase project at Firebase Console.
◦Add your google-services.json (Android).
◦Enable Email/Password Auth and Firestore Database.
4.Hardware Connection:
◦Ensure your SheSecure hardware is paired with your phone via System Bluetooth settings.
◦Open the app, click the Bluetooth icon, and select your device to connect.

🛡️ Safety Warning
This application is designed as a safety aid. Always ensure your hardware device is charged and your phone's Bluetooth and Location services are enabled for maximum protection.


Developed with ❤️ for Women's Safety.
