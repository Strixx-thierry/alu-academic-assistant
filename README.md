# ALU Academic Assistant 🎓

A modern, modular Flutter application designed to help African Leadership University (ALU) students manage their academic life efficiently.

## 🌟 Key Features

- **Dashboard**: Quick overview of overall attendance, today's sessions, and urgent upcoming assignments.
- **Attendance Tracking**: Visual progress indicator with a 75% target warning system.
- **Assignment Management**: Categorized task tracking (Overdue, Pending, Archive) with priority levels.
- **Smart Schedule**: Comprehensive academic calendar tracking Lectures, Workshops, and Mastery sessions.
- **Secure Authentication**: Local user registration and session persistence.

## 🏗️ Architecture & Design Decisions

The project follows a **Modular Layered Architecture** to ensure clean separation of concerns and scalability:

- **`lib/models/`**: Data Layer. Contains immutable data classes with JSON serialization (using the Barrel pattern for easy imports).
- **`lib/services/`**: Logic Layer. Encapsulates business logic and persistence (e.g., `StorageService` using SharedPreferences).
- **`lib/screens/`**: Presentation Layer. Organized by feature modules (Auth, Dashboard, Assignments, Schedule).
- **`lib/widgets/`**: UI Library. Contains reusable, stateless widgets to ensure visual consistency.
- **`lib/theme/`**: Design Tokens. Centralized color and typography definitions.

### Technical Decisions
- **Barrel Files**: Used in `models/` to simplify imports across the project.
- **Service Pattern**: Decouples UI from data storage, making it easier to switch persistence providers.
- **IndexedStack**: Implementation in `MainScreen` preserves state when switching between navigation tabs.
- **Immutability**: Models use `copyWith` patterns to promote predictable state management.

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (^3.10.4)
- Dart SDK (^3.0.0)
- Android Studio / VS Code with Flutter extension

### Steps
1. **Clone the repository**:
   ```bash
   git clone [repository-url]
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

## 🤝 Contribution Guidelines

1. **Naming Conventions**: Use `PascalCase` for classes and `camelCase` for variables and functions.
2. **Modularity**: Always extract reusable UI components into the `widgets/` directory.
3. **Documentation**: Add inline comments for any complex logic or major design decisions.
4. **Commits**: Use descriptive commit messages (e.g., `feat: add priority badges to assignments`).

## 📄 License
This project is for academic purposes at ALU.
