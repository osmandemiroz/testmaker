<div align="center">

# 📚 TestMaker

**A modern Flutter quiz application with AI-powered question generation**

*Transform your PDFs into interactive quizzes with a beautiful, Apple-inspired interface*

[![Flutter](https://img.shields.io/badge/Flutter-3.6.1+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.1+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

</div>

## ✨ Overview

TestMaker is a sleek, modern Flutter application that revolutionizes how you create and take quizzes and flashcards. With its AI-powered generation, you can automatically create quizzes and flashcards from PDF documents using Google Gemini AI. The app features a beautiful, minimal interface inspired by Apple's Human Interface Guidelines—think clean typography, soft cards, smooth animations, and an intuitive user experience.

### 🎯 Key Highlights

- 🤖 **AI-Powered Generation** - Automatically generate quiz questions and flashcards from PDF content
- 📱 **Modern UI/UX** - Beautiful Apple-inspired design with smooth animations and responsive layouts
- 📄 **PDF Integration** - Upload, view, and extract text from PDF documents
- 📚 **Course Management** - Organize quizzes, flashcards, and study materials efficiently
- 🎴 **Interactive Flashcards** - Swipe through flashcards with smooth 3D flip animations
- 💾 **Local Storage** - All data stored locally, works offline
- 🎲 **Randomized Content** - Prevent memorization with shuffled questions, options, and flashcards

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| 📝 **JSON-Driven Quizzes** | Load questions from simple JSON files with customizable options |
| 🎴 **JSON-Driven Flashcards** | Load flashcards from simple JSON files with front/back sides |
| 🗂️ **Course Management** | Organize quizzes, flashcards, and materials into course sections with sidebar navigation |
| 📑 **PDF Study Materials** | Upload PDF files and view them with an integrated PDF viewer |
| 🤖 **AI Quiz Generation** | Automatically generate quiz questions from PDF content using Google Gemini AI |
| ✨ **AI Flashcard Generation** | Automatically generate flashcards from PDF content using Google Gemini AI |
| 💾 **Local Storage** | All courses, quizzes, flashcards, and PDFs stored locally using SharedPreferences |
| 🗑️ **Swipe-to-Delete** | Intuitively delete items with confirmation dialogs |
| 🔀 **Content Randomization** | Questions, options, and flashcards shuffled each time for authentic testing |
| 🎨 **Modern Animated UI** | Card-based layouts with smooth transitions, 3D flip animations, and progress indicators |
| 📊 **Result Summaries** | Detailed score breakdown with percentage and feedback |
| 👆 **Swipe Navigation** | Intuitive swipe gestures for navigating through flashcards |
| 📱 **Responsive Design** | Fully responsive UI that adapts to all screen sizes (mobile, tablet, desktop) |
| 🏗️ **Clean Architecture** | Null-safe, layered architecture with separation of concerns |

---

## 🎨 Design Philosophy

TestMaker follows **Apple's Human Interface Guidelines** to deliver an exceptional user experience:

- ✨ Clean sidebar navigation
- 🌟 Generous use of white space
- 🎭 Soft rounded rectangles and subtle shadows
- 🎬 Smooth animations and transitions
- 📐 Clear visual hierarchy
- 👆 Intuitive swipe gestures for deletion

The codebase emphasizes:
- 🔧 Separation of concerns (models, services, screens, widgets)
- ✅ Null safety throughout
- 🛡️ Comprehensive error handling
- 📝 Extensive code comments for maintainability

---

## 📋 Requirements

- **Flutter SDK**: `>=3.6.1 <4.0.0`
- **Dart SDK**: `>=3.6.1 <4.0.0`

### 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `file_picker` | File selection for JSON quizzes, flashcards, and PDF uploads |
| `shared_preferences` | Local storage for courses and user data |
| `path_provider` | Access to app documents directory for PDF storage |
| `syncfusion_flutter_pdf` | PDF text extraction |
| `syncfusion_flutter_pdfviewer` | PDF viewing |
| `http` | API calls to Google Gemini AI |
| `url_launcher` | Opening external URLs (e.g., API key registration) |

---

## 🏃 Quick Start

### Installation

```bash
# Clone the repository
git clone <https://github.com/osmandemiroz/testmaker>
cd testmaker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 🎯 Quick Quiz

1. Launch the app
2. Tap **"Start Sample Quiz"** on the home screen
3. Answer questions and see your results!

---

## 📖 Usage Guide

### 📝 Using Your Own JSON Quiz

1. Launch the app
2. Look for the **"Use your own JSON"** section on the home screen
3. Tap to select a `.json` file following the format below
4. The app will parse and start the quiz automatically

#### 📄 JSON Format

```json
[
  {
    "id": 1,
    "text": "Which language is used to build this TestMaker app?",
    "options": ["Kotlin", "Swift", "Dart", "JavaScript"],
    "answerIndex": 2
  }
]
```

**Field Descriptions:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | `number` | Numeric identifier for the question |
| `text` | `string` | The question text |
| `options` | `string[]` | Array of answer strings in display order |
| `answerIndex` | `number` | Zero-based index into `options` for the correct answer |

> 💡 **Tip**: Copy `assets/quizzes/sample_quiz.json` as a template for your own quizzes!

#### 📄 Flashcard JSON Format

```json
[
  {
    "id": 1,
    "front": "What is the capital of France?",
    "back": "Paris",
    "explanation": "Paris is the capital and largest city of France, located in the north-central part of the country."
  }
]
```

**Field Descriptions:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | `number` | Numeric identifier for the flashcard |
| `front` | `string` | The question or prompt on the front of the card |
| `back` | `string` | The answer on the back of the card |
| `explanation` | `string` (optional) | Additional context or explanation for the answer |

> 💡 **Tip**: Create your own flashcard JSON files following this format!

---

### 🗂️ Course Management

#### Creating a Course

1. Tap **"New Course"** in the sidebar
2. Enter a course name
3. Tap **"Create"**

#### Managing Content

| Action | Steps |
|--------|-------|
| **Upload Quiz** | Select a course → Tap FAB (bottom-right) → **"Upload Quiz"** → Choose JSON file |
| **Upload Flashcards** | Select a course → Tap FAB (bottom-right) → **"Upload Flashcards"** → Choose JSON file |
| **Upload PDF** | Select a course → Tap FAB (bottom-right) → **"Upload PDF"** → Choose PDF file |
| **View PDF** | Tap on any PDF card in a course |
| **Start Quiz** | Tap on any quiz card (questions are randomized) |
| **Study Flashcards** | Tap on any flashcard set → Swipe left/right to navigate, tap to flip |
| **Delete Items** | Swipe left on any course, quiz, flashcard set, or PDF → Confirm deletion |

---

### 🤖 AI-Powered Content Generation

Transform your PDFs into interactive quizzes and flashcards in seconds!

#### Quiz Generation

1. **Upload a PDF** to a course (see Course Management above)
2. **Tap "Generate Questions"** below the PDF card
3. **Enter question count** when prompted (recommended: 5-20)
4. **Enter your API Key** (if not already set):
   - Get a free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Enter it when prompted
5. **Wait for Generation** - The app extracts text and generates questions
6. **Quiz Ready!** - The generated quiz is automatically added to your course

#### Flashcard Generation

1. **Upload a PDF** to a course (see Course Management above)
2. **Tap "Generate Flashcards"** below the PDF card
3. **Enter flashcard count** when prompted (recommended: 10-30)
4. **Enter your API Key** (if not already set)
5. **Wait for Generation** - The app extracts text and generates flashcards
6. **Flashcards Ready!** - The generated flashcard set is automatically added to your course

> ⚠️ **Important Notes:**
> - The AI generator extracts text from the first 10 pages for performance
> - For best results, ensure your PDF contains readable text (not just images)
> - Internet connection required for AI generation
> - Generated quizzes and flashcards work offline once created
> - Both features use the same Google AI API key

---

## 💾 Data Storage

All data is stored **locally** on your device:

- ✅ **Course metadata** → Stored in SharedPreferences
- ✅ **PDF files** → Copied to app's documents directory
- ✅ **Data persistence** → Survives app restarts
- ✅ **Offline support** → No internet needed for local quizzes, flashcards, and PDFs

> 🌐 **Note**: Internet connection is only required for AI quiz and flashcard generation.

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point and global theming
├── models/
│   ├── question.dart              # Question model with JSON serialization
│   ├── flashcard.dart             # Flashcard model with JSON serialization
│   └── course.dart                # Course model for organizing quizzes/flashcards/PDFs
├── services/
│   ├── quiz_service.dart          # Loads questions from assets or JSON files
│   ├── flashcard_service.dart     # Loads flashcards from assets or JSON files
│   ├── course_service.dart        # CRUD operations for courses (SharedPreferences)
│   ├── pdf_text_extractor.dart    # Extracts text content from PDF files
│   ├── question_generator_service.dart  # AI-powered question generation (Gemini)
│   └── flashcard_generator_service.dart  # AI-powered flashcard generation (Gemini)
├── screens/
│   ├── home_screen.dart           # Main screen with sidebar and course management
│   ├── quiz_screen.dart           # Core quiz flow with randomized questions
│   ├── flashcard_screen.dart      # Interactive flashcard viewer with swipe navigation
│   ├── result_screen.dart         # Score summary screen
│   └── pdf_viewer_screen.dart     # PDF viewer with page navigation
├── widgets/
│   ├── quiz_option_card.dart      # Animated option tiles
│   └── quiz_progress_bar.dart     # Animated quiz progress indicator
└── utils/
    └── responsive_sizer.dart      # Responsive sizing utility for all screen sizes

assets/
├── quizzes/
│   └── sample_quiz.json           # Example quiz file
└── logo/
    └── app_logo.png               # App icon source
```

---

## 🛠️ Development

### Building the App

```bash
# Build APK for Android
flutter build apk

# Build iOS (macOS only)
flutter build ios

# Build with release configuration
flutter build apk --release
```

### Running Tests

```bash
flutter test
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

See the [LICENSE](LICENSE) file for more details.

---

<div align="center">

**Made with ❤️ using Flutter**

*Inspired by Apple's Human Interface Guidelines*

[⬆ Back to Top](#-testmaker)

</div>
