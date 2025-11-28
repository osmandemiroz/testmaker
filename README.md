# TestMaker

TestMaker is a modern Flutter quiz application with course management, PDF viewing, and local storage. The UI follows Apple's Human Interface Guidelines with clean typography, soft cards, subtle animations, and a sleek sidebar navigation system.

## Features

### Core Quiz Functionality
- **JSON-driven quizzes**: Questions, options, and correct answers are loaded from simple JSON files
- **Modern, animated UI**: Card-based question layout, animated progress bar, and smooth screen transitions
- **One question at a time**: Focused quiz experience with immediate feedback on each answer
- **Result summary**: Final score and percentage with a short textual summary
- **Sample quiz**: Quick access to a bundled sample quiz for testing

### Course Management
- **Course sections**: Create and organize courses (e.g., "Math 101", "History")
- **Sidebar navigation**: Clean left sidebar menu for easy course navigation (drawer on mobile)
- **Local storage**: All courses, quizzes, and PDFs are stored locally using SharedPreferences and persist across app restarts
- **Swipe-to-delete**: Swipe left on any course in the sidebar to delete it (with confirmation)

### PDF Study Materials
- **PDF upload**: Upload PDF files to any course for study materials
- **PDF viewer**: Full-featured PDF viewer with zoom, scroll, and page navigation
- **Local storage**: PDFs are stored in the app's documents directory and organized by course
- **Swipe-to-delete**: Swipe left on any PDF card to delete it (with confirmation)

### Quiz Management
- **Multiple quizzes per course**: Upload multiple quiz JSON files to each course
- **Swipe-to-delete**: Swipe left on any quiz card to delete it (with confirmation)
- **Quick access**: Start any quiz directly from the course view

### UI/UX
- **Apple HIG design**: Generous white space, soft rounded corners, subtle shadows, and smooth animations
- **Responsive layout**: Adapts to different screen sizes (sidebar on desktop, drawer on mobile)
- **Beautiful dialogs**: Animated course creation dialog with focus states
- **Custom app icon**: Uses `flutter_launcher_icons` with your custom logo

## Project Structure

```
lib/
├── main.dart                    # App entry point and global theming
├── models/
│   ├── question.dart           # Question model with JSON serialization
│   └── course.dart             # Course model (quizzes + PDFs)
├── services/
│   ├── quiz_service.dart       # Loads questions from assets or files
│   └── course_service.dart     # Manages courses, quizzes, and PDFs with local storage
├── screens/
│   ├── home_screen.dart        # Main screen with sidebar and course management
│   ├── quiz_screen.dart        # Core quiz flow (one question at a time)
│   ├── result_screen.dart      # Score summary screen
│   └── pdf_viewer_screen.dart  # Full-featured PDF viewer
└── widgets/
    ├── quiz_option_card.dart   # Animated option tiles
    └── quiz_progress_bar.dart  # Animated quiz progress indicator

assets/
├── quizzes/
│   └── sample_quiz.json        # Example quiz file
└── logo/
    └── app_logo.png            # Custom app icon source
```

## JSON Format

The quiz JSON is a list of question objects:

```json
[
  {
    "id": 1,
    "text": "Which language is used to build this TestMaker app?",
    "options": ["Kotlin", "Swift", "Dart", "JavaScript"],
    "answerIndex": 2
  },
  {
    "id": 2,
    "text": "What is the capital of France?",
    "options": ["London", "Berlin", "Paris", "Madrid"],
    "answerIndex": 2
  }
]
```

- **id**: Numeric identifier for the question
- **text**: Question text
- **options**: Array of answer strings, in display order
- **answerIndex**: Zero-based index into `options` for the correct answer

To create your own quiz, create a JSON file following this format and upload it to a course.

## Requirements

- Flutter SDK `>=3.6.1 <4.0.0`

### Main Dependencies

- `flutter` - Flutter SDK
- `file_picker: ^8.1.5` - File selection for quizzes and PDFs
- `shared_preferences: ^2.3.3` - Local storage for courses and metadata
- `path_provider: ^2.1.4` - File system paths for PDF storage
- `syncfusion_flutter_pdfviewer: ^28.2.8` - PDF viewing functionality
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Dev Dependencies

- `flutter_launcher_icons: ^0.13.1` - Generate app icons from logo

## Running the App

From the project root:

```bash
flutter pub get
flutter run
```

## Usage Guide

### Creating a Course

1. Launch the app
2. In the left sidebar, tap **"New Course"**
3. Enter a course name (e.g., "Math 101", "History")
4. Tap **"Create"**

### Uploading a Quiz

1. Select a course from the sidebar
2. In the course view, tap **"Upload Quiz"**
3. Select a `.json` file that follows the format shown above
4. The quiz will be added to the course and appear in the "Quizzes" section

### Taking a Quiz

1. Select a course from the sidebar
2. In the "Quizzes" section, tap on any quiz card
3. Answer questions one at a time
4. View your results at the end

### Uploading a PDF

1. Select a course from the sidebar
2. In the course view, tap **"Upload PDF"**
3. Select a `.pdf` file from your device
4. The PDF will be added to the course and appear in the "Study Materials" section

### Viewing a PDF

1. Select a course from the sidebar
2. In the "Study Materials" section, tap on any PDF card
3. The PDF will open in a full-screen viewer with zoom and scroll capabilities

### Deleting Items

- **Delete a course**: Swipe left on any course in the sidebar → confirm deletion
- **Delete a PDF**: Swipe left on any PDF card → confirm deletion
- **Delete a quiz**: Swipe left on any quiz card → confirm deletion

All deletions require confirmation to prevent accidental data loss.

## Data Storage

- **Courses and metadata**: Stored in SharedPreferences (persists across app restarts)
- **PDF files**: Stored in the app's documents directory at `app_documents/courses/{courseId}/`
- **Quizzes**: Stored as JSON in SharedPreferences (questions are embedded in course data)

All data is stored locally on the device. No cloud sync or external services are used.

## Customization

### Changing the App Icon

1. Replace `assets/logo/app_logo.png` with your own logo (recommended: 1024x1024px)
2. Run: `dart run flutter_launcher_icons`
3. The new icon will be generated for both Android and iOS

### Adding Sample Quizzes

1. Create JSON files following the format shown above
2. Place them in `assets/quizzes/`
3. Add them to `pubspec.yaml` under `flutter: assets:`
4. Update `QuizService.defaultQuizAssetPath` if needed

## Architecture

The app follows a clean, layered architecture:

- **Models**: Immutable data classes with JSON serialization
- **Services**: Business logic and data persistence (no UI dependencies)
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components

This separation makes the codebase easy to understand, test, and maintain.

## Design Philosophy

TestMaker's UI is heavily influenced by Apple's Human Interface Guidelines:

- **Clarity**: Clear visual hierarchy and readable typography
- **Deference**: Content is the focus, UI elements support it
- **Depth**: Subtle shadows and animations provide visual depth
- **Motion**: Smooth, purposeful animations that enhance usability
- **Consistency**: Consistent patterns throughout the app

## License

This project is provided as-is for educational and personal use.
