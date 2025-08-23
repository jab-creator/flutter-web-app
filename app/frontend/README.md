# Flutter Web App

A modern Flutter web application demonstrating authentication, navigation, and task management with a clean, organized codebase.

## Features

- 🔐 **Authentication Flow**: Login/logout with form validation
- 🎨 **Material Design 3**: Modern UI with responsive design
- 📱 **Multi-page Navigation**: Bottom navigation with 3 main sections
- ✅ **Task Management**: Add, view, and delete tasks
- 🏗️ **Clean Architecture**: Well-organized folder structure
- 🔄 **State Management**: Proper state handling across components

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (future use)
├── pages/                    # Individual page widgets
│   ├── home_page.dart       # Dashboard/home content
│   ├── tasks_page.dart      # Task management page
│   └── about_page.dart      # About Flutter information
├── screens/                  # Full screen components
│   ├── login_screen.dart    # Authentication screen
│   └── home_screen.dart     # Main app screen with navigation
├── services/                 # Business logic and services
│   └── auth_service.dart    # Authentication service
└── widgets/                  # Reusable widgets
    └── auth_wrapper.dart    # Authentication state wrapper
```

## Architecture

### Separation of Concerns

- **main.dart**: App configuration and entry point
- **screens/**: Complete screen layouts with navigation
- **pages/**: Individual page content without navigation
- **services/**: Business logic and data management
- **widgets/**: Reusable UI components
- **models/**: Data structures (ready for future expansion)

### Authentication Flow

1. **AuthWrapper**: Manages authentication state
2. **AuthService**: Handles login/logout logic
3. **LoginScreen**: User interface for authentication
4. **HomeScreen**: Main app interface after login

## Getting Started

### Prerequisites

- Flutter SDK (3.24.3 or later)
- Web browser for testing

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run the application:

```bash
flutter run -d web-server --web-port 12000 --web-hostname 0.0.0.0
```

### Demo Credentials

This is a demo application. Use any username with a password of at least 6 characters:

- **Username**: demo
- **Password**: password123

## Pages Overview

### 🏠 Home Page
- Personalized welcome message
- Feature showcase with chips
- Information cards grid
- App overview and statistics

### ✅ Tasks Page
- Add new tasks with input validation
- View all tasks in a clean list
- Delete tasks with confirmation
- Empty state with helpful messaging

### ℹ️ About Page
- Flutter framework information
- Key features explanation
- Demo app capabilities
- Scrollable content with cards

## Technical Highlights

- **Responsive Design**: Adapts to different screen sizes
- **Form Validation**: Proper input validation and error handling
- **Loading States**: Visual feedback during async operations
- **Error Handling**: User-friendly error messages
- **Clean Code**: Well-organized, maintainable codebase
- **Material Design 3**: Modern UI components and theming

## Future Enhancements

- Add data persistence (local storage/database)
- Implement real authentication API
- Add user profile management
- Include more advanced task features
- Add routing with named routes
- Implement state management (Provider/Bloc)

## Development

### Hot Reload

The app supports Flutter's hot reload for rapid development:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Code Organization

Each component has a single responsibility:
- Services handle business logic
- Screens manage full-page layouts
- Pages contain specific content
- Widgets are reusable components

This structure makes the codebase scalable and maintainable for larger applications.
