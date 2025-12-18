<div align="center">

## 📚 TestMaker

**A modern Flutter quiz & flashcard application with AI-powered content generation**

*Transform your PDFs into interactive quizzes and flashcards with a beautiful, Apple-inspired interface.*

[![Flutter](https://img.shields.io/badge/Flutter-3.6.1+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.1+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey)](#-requirements)

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
- ✏️ **Custom Naming** - Rename quizzes, PDFs, and flashcard sets for better organization
- 🏗️ **MVC Architecture** - Clean, maintainable codebase with separation of concerns

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| 📝 **Text-Based Content** | Paste quiz or flashcard content directly (no JSON files needed) |
| 🎴 **Content Templates** | Ready-made prompts for AI agents to generate quiz and flashcard content |
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
| ✏️ **Custom Naming** | Long-press any quiz, PDF, or flashcard set to rename it with custom names |
| 📱 **Responsive Design** | Fully responsive UI that adapts to all screen sizes (mobile, tablet, desktop) |
| 🏗️ **MVC Architecture** | Clean MVC architecture with controllers, models, and views for maintainability |

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
- 🏗️ **MVC Architecture** - Clean separation with controllers managing business logic, models for data, and views for UI
- 🔧 **Modular Component Structure** - Highly organized, reusable components split into dialogs, items, views, widgets, and templates
- ✅ Null safety throughout
- 🛡️ Comprehensive error handling
- 📝 Extensive code comments for maintainability
- 🔄 Reactive state management using ChangeNotifier pattern
- 📦 **Code Refactoring** - Reduced `home_screen.dart` from ~5,300 lines to ~1,086 lines (80% reduction) through systematic component extraction

---

## 📑 Table of Contents

- **[Overview](#-overview)**
- **[Key Highlights](#-key-highlights)**
- **[Design Philosophy](#-design-philosophy)**
- **[Requirements](#-requirements)**
- **[Quick Start](#-quick-start)**
- **[Usage Guide](#-usage-guide)**
  - **[Adding Quiz and Flashcard Content](#-adding-quiz-and-flashcard-content)**
  - **[Course Management](#-course-management)**
  - **[AI-Powered Content Generation](#-ai-powered-content-generation)**
- **[Data Storage](#-data-storage)**
- **[Project Structure](#-project-structure)**
- **[Recent Refactoring](#-recent-refactoring-2024)**
- **[Development](#-development)**
- **[Contributing](#-contributing)**
- **[License](#-license)**

---

## 📋 Requirements

- **Flutter SDK**: `>=3.6.1 <4.0.0`
- **Dart SDK**: `>=3.6.1 <4.0.0`

### 📦 Core Dependencies

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

## 🖼️ Screenshots

> _Tip: Add real screenshots here (`/screenshots` directory) to showcase the Apple-inspired UI._

- **Home Screen** – Sidebar navigation with courses, quizzes, flashcards, and PDFs
- **Quiz Flow** – Animated question cards, progress bar, and score summary
- **Flashcards** – Swipeable 3D flip cards with front/back content
- **PDF Viewer** – Integrated viewer with navigation and action buttons

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

### 🎯 Quick Quiz (Sample)

1. Launch the app
2. Tap **"Start Sample Quiz"** on the home screen
3. Answer questions and see your results!

---

## 📖 Usage Guide

### 📝 Adding Quiz and Flashcard Content

#### Method 1: Paste Text Content (Recommended)

1. Launch the app and select a course
2. Tap the **FAB (Floating Action Button)** in the bottom-right corner
3. Choose **"Upload Quiz"** or **"Upload Flashcards"**
4. Paste your content in the text field
5. The app will automatically parse and add the content

The app supports both JSON format and simple text format. You can paste:
- **JSON arrays** of questions or flashcards
- **Simple text** that the app will parse intelligently

#### Method 2: Use Content Templates

1. Scroll to the **"Content Templates"** section on the home screen
2. Tap **"Quiz"** or **"Flashcard"** button
3. Select the type and number of items you want
4. Tap **"Generate"** to create a prompt
5. The prompt is automatically copied to your clipboard
6. Use the prompt with your AI agent (e.g., ChatGPT, Claude, etc.)
7. Paste the generated content back into the app

#### 📄 Supported Formats

**Quiz Format (JSON):**
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

**Flashcard Format (JSON):**
```json
[
  {
    "id": 1,
    "front": "What is the capital of France?",
    "back": "Paris",
    "explanation": "Paris is the capital and largest city of France."
  }
]
```

> 💡 **Tip**: The app can parse both JSON and simple text formats, making it easy to add content from any source!

---

### 🗂️ Course Management

#### Creating a Course

1. Tap **"New Course"** in the sidebar
2. Enter a course name
3. Tap **"Create"**

#### Managing Content

| Action | Steps |
|--------|-------|
| **Add Quiz** | Select a course → Tap FAB (bottom-right) → **"Upload Quiz"** → Paste quiz content |
| **Add Flashcards** | Select a course → Tap FAB (bottom-right) → **"Upload Flashcards"** → Paste flashcard content |
| **Upload PDF** | Select a course → Tap FAB (bottom-right) → **"Upload PDF"** → Choose PDF file |
| **View PDF** | Tap on any PDF card in a course |
| **Start Quiz** | Tap on any quiz card (questions are randomized) |
| **Study Flashcards** | Tap on any flashcard set → Swipe left/right to navigate, tap to flip |
| **Rename Items** | Long-press any quiz, PDF, or flashcard set card → Enter new name → Save |
| **Delete Items** | Swipe left on any course, quiz, flashcard set, or PDF → Confirm deletion |

---

### 🤖 AI-Powered Content Generation

Transform your PDFs into interactive quizzes and flashcards in seconds!

#### 🧠 Quiz Generation

1. **Upload a PDF** to a course (see Course Management above)
2. **Tap "Generate Questions"** below the PDF card
3. **Enter question count** when prompted (recommended: 5-20)
4. **Enter your API Key** (if not already set):
   - Get a free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Enter it when prompted
5. **Wait for Generation** - The app extracts text and generates questions
6. **Quiz Ready!** - The generated quiz is automatically added to your course

#### 🧠 Flashcard Generation

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

## 🔑 API Key Configuration

TestMaker uses **Google Gemini** for AI-powered quiz and flashcard generation.

- **Step 1**: Obtain an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
- **Step 2**: Launch the app and trigger **Generate Questions** or **Generate Flashcards**
- **Step 3**: Enter your API key when prompted (it is stored locally for reuse)
- **Step 4**: You can update/change the key at any time by triggering generation again

> ⚠️ **Security Note**: Your API key is stored locally on your device and is **never** uploaded to any external server by this app.

---

## 💾 Data Storage

All data is stored **locally** on your device:

- ✅ **Course metadata** → Stored in SharedPreferences
- ✅ **PDF files** → Copied to app's documents directory
- ✅ **Data persistence** → Survives app restarts
- ✅ **Offline support** → No internet needed for local quizzes, flashcards, and PDFs

> 🌐 **Note**: Internet connection is only required for AI quiz and flashcard generation.

---

## 🧱 Architecture & Project Structure

```
lib/
├── main.dart                      # App entry point and global theming
├── models/
│   ├── question.dart              # Question model with JSON serialization
│   ├── flashcard.dart             # Flashcard model with JSON serialization
│   └── course.dart                # Course model for organizing quizzes/flashcards/PDFs
├── controllers/
│   ├── home_controller.dart       # Business logic for course management and content operations
│   ├── quiz_controller.dart       # Quiz state management and navigation
│   └── flashcard_controller.dart  # Flashcard state management and navigation
├── services/
│   ├── quiz_service.dart          # Loads questions from assets or JSON files
│   ├── flashcard_service.dart     # Loads flashcards from assets or JSON files
│   ├── course_service.dart        # CRUD operations for courses (SharedPreferences)
│   ├── pdf_text_extractor.dart    # Extracts text content from PDF files
│   ├── question_generator_service.dart  # AI-powered question generation (Gemini)
│   └── flashcard_generator_service.dart  # AI-powered flashcard generation (Gemini)
├── screens/
│   ├── home_screen.dart           # Main screen with sidebar and course management (refactored)
│   ├── quiz_screen.dart           # Core quiz flow with randomized questions
│   ├── flashcard_screen.dart      # Interactive flashcard viewer with swipe navigation
│   ├── result_screen.dart         # Score summary screen
│   ├── pdf_viewer_screen.dart     # PDF viewer with page navigation
│   └── home/                      # Modular home screen components
│       ├── dialogs/               # Reusable dialog components
│       │   ├── create_course_dialog.dart
│       │   ├── delete_confirmation_dialogs.dart
│       │   ├── flashcard_prompt_dialog.dart
│       │   ├── prompt_preview_dialog.dart
│       │   ├── quiz_prompt_dialog.dart
│       │   ├── rename_dialog.dart
│       │   ├── settings_dialog.dart
│       │   └── text_input_dialog.dart
│       ├── items/                 # Reusable item components
│       │   ├── course_item.dart
│       │   ├── flashcard_card.dart
│       │   ├── module_card.dart
│       │   ├── module_items.dart
│       │   ├── pdf_card.dart
│       │   ├── quiz_card.dart
│       │   └── reorderable_items.dart
│       ├── templates/             # Content template generators
│       │   ├── content_templates_section.dart
│       │   └── prompt_generator.dart
│       ├── views/                 # View components
│       │   ├── compact_layout.dart
│       │   ├── course_content_view.dart
│       │   ├── empty_course_state.dart
│       │   ├── empty_courses_state.dart
│       │   ├── empty_modules_state.dart
│       │   ├── module_contents.dart
│       │   ├── modules_view.dart
│       │   └── sidebar.dart
│       └── widgets/               # Reusable widget components
│           ├── animated_action_button.dart
│           ├── animated_template_button.dart
│           ├── fab_menu.dart
│           └── swipe_indicator_arrow.dart
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

## 🔄 Recent Refactoring (2024)

### Code Organization Improvements

The `home_screen.dart` file has been significantly refactored to improve maintainability and code organization:

#### 📊 Refactoring Statistics
- **Original Size**: ~5,312 lines
- **Current Size**: ~1,086 lines
- **Reduction**: ~4,226 lines (80% reduction)
- **Components Extracted**: 30+ reusable components

#### 🗂️ New Modular Structure

The home screen has been split into a well-organized modular structure:

**Dialogs** (`lib/screens/home/dialogs/`)
- `create_course_dialog.dart` - Course creation dialog
- `delete_confirmation_dialogs.dart` - Delete confirmation dialogs for PDFs, quizzes, and flashcards
- `flashcard_prompt_dialog.dart` - Flashcard prompt generation dialog
- `quiz_prompt_dialog.dart` - Quiz prompt generation dialog
- `prompt_preview_dialog.dart` - Preview dialog for generated prompts
- `rename_dialog.dart` - Reusable rename dialog
- `settings_dialog.dart` - App settings dialog
- `text_input_dialog.dart` - Text input dialog for pasting content

**Items** (`lib/screens/home/items/`)
- `course_item.dart` - Course list item with swipe-to-delete
- `flashcard_card.dart` - Flashcard set card component
- `module_card.dart` - Module/course card with expandable content
- `module_items.dart` - Module content items (PDFs, quizzes, flashcards)
- `pdf_card.dart` - PDF card with expandable actions
- `quiz_card.dart` - Quiz card component
- `reorderable_items.dart` - Reorderable items for drag-and-drop functionality

**Views** (`lib/screens/home/views/`)
- `compact_layout.dart` - Compact layout for mobile devices (drawer-based)
- `course_content_view.dart` - Course content display view
- `empty_course_state.dart` - Empty state for courses with no content
- `empty_courses_state.dart` - Empty state when no courses exist
- `empty_modules_state.dart` - Empty state for modules view
- `module_contents.dart` - Module contents display
- `modules_view.dart` - Main modules view
- `sidebar.dart` - Sidebar navigation component

**Widgets** (`lib/screens/home/widgets/`)
- `animated_action_button.dart` - Animated action button for expandable sections
- `animated_template_button.dart` - Animated template button with staggered animations
- `fab_menu.dart` - Floating action button menu with expandable options
- `swipe_indicator_arrow.dart` - Swipe indicator animation for drawer discovery

**Templates** (`lib/screens/home/templates/`)
- `content_templates_section.dart` - Content templates section UI
- `prompt_generator.dart` - AI prompt generation utilities

#### ✨ Benefits of Refactoring

1. **Improved Maintainability** - Each component has a single responsibility
2. **Better Reusability** - Components can be easily reused across the app
3. **Easier Testing** - Smaller, focused components are easier to test
4. **Enhanced Readability** - Clear structure makes code navigation intuitive
5. **Reduced Complexity** - Main screen file is now much more manageable
6. **Better Collaboration** - Multiple developers can work on different components simultaneously

#### 🎯 Key Improvements

- **Text-Based Content Input**: Removed JSON file uploads in favor of simple text paste, making the app more user-friendly
- **Content Templates**: Added ready-made prompts for AI agents to generate quiz and flashcard content
- **Smooth Animations**: Enhanced UI with animations for expandable areas, template sections, and swipe indicators
- **Responsive Design**: Improved responsive layouts with dedicated compact layout component
- **Modular Dialogs**: All dialogs are now reusable components with consistent styling

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

*Designed following Apple’s Human Interface Guidelines — clean, minimal, and delightful to use.*

[⬆ Back to Top](#-testmaker)

</div>
