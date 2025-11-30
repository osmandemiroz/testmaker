## TestMaker

TestMaker is a modern Flutter quiz application that loads questions from JSON.
The UI takes cues from Apple's Human Interface Guidelines: clean typography,
soft cards, and subtle animations, while keeping the codebase small and easy
to customize.

### Features

- **JSON‑driven quizzes**: Questions, options, and correct answers are loaded
  from a simple JSON file.
- **Course management**: Organize quizzes and study materials into course sections
  with a sidebar navigation menu.
- **PDF study materials**: Upload PDF files to courses for study, with an
  integrated PDF viewer.
- **AI-powered quiz generation**: Automatically generate quiz questions from PDF
  content using Google Gemini AI.
- **Local storage**: All courses, quizzes, and PDFs are stored locally using
  SharedPreferences, persisting across app restarts.
- **Swipe-to-delete**: Intuitively delete courses, quizzes, and PDFs by swiping
  left with confirmation dialogs.
- **Question randomization**: Questions and answer options are shuffled each
  time you start a quiz to prevent memorization.
- **Modern, animated UI**: Card‑based question layout, animated progress bar,
  and smooth screen transitions.
- **One question at a time**: Focused quiz experience with immediate feedback
  on each answer.
- **Result summary**: Final score and percentage with a short textual summary.
- **Null‑safe, layered architecture**: Models, services, screens, and widgets
  are separated for clarity and reuse.

### Project structure

- `lib/main.dart` – App entry point and global theming.
- `lib/models/`
  - `question.dart` – `Question` model with `fromJson` / `toJson` and randomization utilities.
  - `course.dart` – `Course` model for organizing quizzes and PDFs.
- `lib/services/`
  - `quiz_service.dart` – Loads questions from bundled assets or user‑selected JSON files.
  - `course_service.dart` – Manages CRUD operations for courses using SharedPreferences.
  - `pdf_text_extractor.dart` – Extracts text content from PDF files.
  - `question_generator_service.dart` – Generates quiz questions from text using Google Gemini AI.
- `lib/screens/`
  - `home_screen.dart` – Main screen with sidebar menu, course management, and quiz/PDF uploads.
  - `quiz_screen.dart` – Core quiz flow; shows one question at a time with randomized order.
  - `result_screen.dart` – Score summary screen.
  - `pdf_viewer_screen.dart` – PDF viewer with page navigation.
- `lib/widgets/`
  - `quiz_option_card.dart` – Animated option tiles.
  - `quiz_progress_bar.dart` – Animated quiz progress indicator.
- `assets/quizzes/sample_quiz.json` – Example quiz file.
- `assets/logo/app_logo.png` – App icon source.

### JSON format

The quiz JSON is a list of question objects:

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

- **id**: Numeric identifier.
- **text**: Question text.
- **options**: Array of answer strings, in display order.
- **answerIndex**: Zero‑based index into `options` for the correct answer.

To create your own quiz, copy `assets/quizzes/sample_quiz.json`,
adjust the questions, and keep the same structure.

### Requirements

- Flutter SDK `>=3.6.1 <4.0.0`

Main dependencies:

- `flutter` – Flutter SDK
- `file_picker` – File selection for JSON quizzes and PDF uploads
- `shared_preferences` – Local storage for courses and user data
- `path_provider` – Access to app documents directory for PDF storage
- `syncfusion_flutter_pdf` – PDF text extraction
- `syncfusion_flutter_pdfviewer` – PDF viewing
- `http` – API calls to Google Gemini AI
- `url_launcher` – Opening external URLs (e.g., API key registration)

### Running the app

From the project root:

```bash
flutter pub get
flutter run
```

### Usage

#### Quick Start Quiz

1. Launch the app.
2. On the home screen, tap **"Start Sample Quiz"** to use the bundled sample quiz.

#### Using Your Own JSON Quiz

1. Launch the app.
2. On the home screen, look for the **"Use your own JSON"** section.
2. Tap to select a `.json` file that follows the format shown above.
3. The app will parse the file and start a quiz based on those questions.

#### Course Management

1. **Create a course**: Tap **"New Course"** in the sidebar, enter a course name, and tap **"Create"**.
2. **Upload a quiz**: Select a course, then tap **"Upload Quiz"** and choose a JSON file.
3. **Upload a PDF**: Select a course, then tap **"Upload PDF"** and choose a PDF file.
4. **View PDF**: Tap on any PDF card in a course to open the PDF viewer.
5. **Start a quiz**: Tap on any quiz card in a course to start that quiz (questions and options are randomized).
6. **Delete items**: Swipe left on any course, quiz, or PDF to delete it (with confirmation).

#### AI-Powered Quiz Generation

1. Upload a PDF to a course (see above).
2. Below the PDF card, tap **"Generate Questions"**.
3. If prompted, enter your Google AI API key (get one from [Google AI Studio](https://makersuite.google.com/app/apikey)).
4. The app will extract text from the PDF and generate quiz questions using Google Gemini AI.
5. The generated quiz will be added to the course automatically.

**Note**: The AI quiz generator extracts text from the first 10 pages of the PDF for performance. For best results, ensure your PDF contains readable text (not just images).

### Data Storage

All courses, quizzes, and PDFs are stored locally on your device:
- Course metadata is stored in SharedPreferences.
- PDF files are copied to the app's documents directory.
- Data persists across app restarts.
- No internet connection is required for local quizzes and PDFs (AI generation requires internet).

### Design Philosophy

TestMaker follows Apple's Human Interface Guidelines:
- Clean sidebar navigation
- Generous use of white space
- Soft rounded rectangles and subtle shadows
- Smooth animations and transitions
- Clear visual hierarchy
- Intuitive swipe gestures for deletion

The codebase emphasizes:
- Separation of concerns (models, services, screens, widgets)
- Null safety throughout
- Comprehensive error handling
- Extensive code comments for maintainability
