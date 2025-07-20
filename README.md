# Task Manager Pro - Local Storage Edition (Live Link: https://taskmanager1122.netlify.app/)

A comprehensive task management application built with Flutter featuring local storage, notifications, and advanced task management capabilities.

## 🚀 Features

### Core Features
- ✅ **Complete Task Management**: Create, edit, delete, and complete tasks
- ✅ **Priority System**: Four priority levels (Low, Medium, High, Urgent) with visual indicators
- ✅ **Categories**: Organize tasks with custom categories
- ✅ **Due Dates & Times**: Set specific due dates and times for tasks
- ✅ **Search & Filter**: Advanced search and filtering capabilities
- ✅ **Sorting**: Multiple sorting options (date, priority, title, due date)

### Advanced Features
- 🔔 **Smart Notifications**: Local notifications for due dates and overdue tasks
- 📊 **Analytics Dashboard**: Progress tracking and task statistics
- 🌙 **Dark Theme**: Beautiful dark mode support
- 📤 **Export/Import**: Export tasks to JSON/CSV and import from JSON
- 📱 **Responsive Design**: Optimized for all screen sizes
- ⚡ **Offline First**: Works completely offline with local storage

### Premium Features
- 📈 **Advanced Analytics**: Detailed progress tracking and insights
- 🎯 **Smart Prioritization**: Visual priority indicators and sorting
- ⏰ **Overdue Detection**: Automatic detection of overdue and due-soon tasks
- 🔄 **Data Management**: Backup, restore, and clear data options
- ⚙️ **Customizable Settings**: Personalize defaults and preferences

## 🏗️ Architecture

### Local Storage Architecture
- **SharedPreferences**: Primary storage for tasks and settings
- **JSON Serialization**: Efficient data persistence
- **Offline First**: No internet connection required

### State Management
- **Provider Pattern**: Centralized state management
- **Reactive UI**: Real-time updates across the application
- **Clean Architecture**: Separation of concerns

### Project Structure
\`\`\`
lib/
├── models/           # Data models (Task, enums)
├── providers/        # State management (TaskProvider)
├── services/         # Business logic (Storage, Notifications, Export)
├── screens/          # UI screens (TaskList, AddEdit, Settings)
├── widgets/          # Reusable UI components
└── utils/           # Utilities and themes
\`\`\`

## 🛠️ Technical Stack

### Core Technologies
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Provider**: State management solution
- **Material Design 3**: Modern UI components

### Local Features
- **SharedPreferences**: Local data persistence
- **Flutter Local Notifications**: Push notifications
- **Path Provider**: File system access
- **Share Plus**: File sharing capabilities
- **Timezone**: Notification scheduling

## 📱 Key Features

### Task Management
- **Create Tasks**: Add tasks with title, description, category, priority, and due date
- **Edit Tasks**: Modify any task property
- **Complete Tasks**: Mark tasks as done with completion tracking
- **Delete Tasks**: Remove tasks with confirmation dialogs
- **Swipe Actions**: Swipe to delete tasks

### Organization
- **Categories**: Custom categories for task organization
- **Priorities**: Visual priority system with color coding
- **Filtering**: Filter by status (All, Pending, Completed, Overdue, Due Soon)
- **Sorting**: Sort by date, priority, title, or due date
- **Search**: Real-time search across all task fields

### Notifications
- **Due Date Alerts**: Notifications 1 hour before due time
- **Overdue Alerts**: Notifications when tasks become overdue
- **Smart Scheduling**: Timezone-aware notification scheduling
- **Permission Handling**: Proper notification permission requests

### Data Management
- **Export Options**: JSON and CSV export formats
- **Import Capability**: Import tasks from JSON files
- **Backup System**: Complete app backup including settings
- **Statistics Export**: Detailed analytics and insights
- **Data Clearing**: Options to clear completed tasks or all data

### Settings & Customization
- **Theme Toggle**: Switch between light and dark themes
- **Default Settings**: Set default priority and category
- **Notification Controls**: Enable/disable notifications
- **Storage Management**: View storage usage and clear data
- **Privacy Policy**: Built-in privacy information

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/yourusername/task-manager-local.git
   cd task-manager-local
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Run the app**
   \`\`\`bash
   flutter run
   \`\`\`

### Build for Release

**Android:**
\`\`\`bash
flutter build apk --release
flutter build appbundle --release
\`\`\`

**iOS:**
\`\`\`bash
flutter build ios --release
\`\`\`

## 📊 Data Storage

### Local Storage Structure
- **Tasks**: Stored as JSON in SharedPreferences
- **Settings**: App preferences and defaults
- **Theme**: Dark/light mode preference
- **Categories**: Dynamic category list

### Data Format
\`\`\`json
{
  "id": "unique-task-id",
  "title": "Task Title",
  "description": "Task Description",
  "category": "Work",
  "priority": "high",
  "isCompleted": false,
  "createdAt": "2024-01-01T10:00:00.000Z",
  "dueDate": "2024-01-02T15:00:00.000Z",
  "completedAt": null,
  "updatedAt": "2024-01-01T10:00:00.000Z"
}
\`\`\`

## 🔔 Notifications

### Notification Types
- **Due Soon**: 1 hour before due time
- **Overdue**: When task becomes overdue
- **Instant**: Immediate notifications for actions

### Notification Features
- **Smart Scheduling**: Only schedules future notifications
- **Automatic Cancellation**: Cancels notifications when tasks are completed
- **Permission Handling**: Requests permissions appropriately
- **Cross-Platform**: Works on both Android and iOS

## 📈 Analytics & Statistics

### Built-in Analytics
- **Completion Rate**: Overall task completion percentage
- **Priority Distribution**: Tasks breakdown by priority
- **Category Usage**: Most used categories
- **Overdue Tracking**: Overdue and due-soon task counts
- **Monthly Statistics**: Task creation and completion trends

### Export Capabilities
- **JSON Export**: Complete task data with metadata
- **CSV Export**: Spreadsheet-compatible format
- **Statistics Export**: Analytics and insights data
- **Backup Export**: Complete app backup

## ⚙️ Configuration

### App Settings
- **Default Priority**: Set default task priority
- **Default Category**: Set default task category
- **Notifications**: Enable/disable notifications
- **Auto-delete**: Automatically delete old completed tasks
- **Theme**: Light/dark mode preference

### Storage Management
- **View Usage**: See how much storage the app uses
- **Clear Completed**: Remove all completed tasks
- **Clear All Data**: Reset the entire app
- **Export Backup**: Create complete backup

## 🔐 Privacy & Security

### Privacy Features
- **Local Only**: All data stays on your device
- **No Cloud**: No data sent to external servers
- **User Control**: Full control over your data
- **Export/Delete**: Easy data portability and deletion

### Data Handling
- **Secure Storage**: Uses platform-secure storage
- **No Tracking**: No user tracking or analytics
- **Transparent**: Open source and transparent code

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: Amazing framework and documentation
- **Material Design**: Beautiful design system
- **Open Source Community**: Inspiration and packages

---

**Task Manager Pro** - A complete local storage task management solution built with Flutter

*Perfect for users who want full control over their data with no cloud dependencies.*
\`\`\`

This local storage implementation provides:

## 🎯 **Key Benefits:**

### 1. **Complete Offline Functionality** ✅
- No internet connection required
- All data stored locally on device
- Fast performance with no network delays

### 2. **Advanced Local Features** 🔔
- Smart local notifications
- Comprehensive export/import
- Detailed analytics and statistics
- Customizable settings and preferences

### 3. **Privacy Focused** 🔐
- No data leaves your device
- No user tracking or analytics
- Full user control over data
- Easy export and deletion

### 4. **Production Ready** 🚀
- Comprehensive error handling
- Clean architecture
- Responsive design
- Material Design 3 UI

### 5. **Rich Feature Set** 📊
- Priority system with visual indicators
- Category organization
- Advanced search and filtering
- Multiple sorting options
- Progress tracking and statistics

This implementation is perfect for users who want a powerful task management app without any cloud dependencies or privacy concerns.
