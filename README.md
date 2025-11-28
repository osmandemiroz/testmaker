## TestMaker

TestMaker is a modern Flutter quiz application that loads questions from JSON.
The UI takes cues from Apple's Human Interface Guidelines: clean typography,
soft cards, and subtle animations, while keeping the codebase small and easy
to customize.

### Features

- **JSON‑driven quizzes**: Questions, options, and correct answers are loaded
  from a simple JSON file.
- **Modern, animated UI**: Card‑based question layout, animated progress bar,
  and smooth screen transitions.
- **One question at a time**: Focused quiz experience with immediate feedback
  on each answer.
- **Result summary**: Final score and percentage with a short textual summary.
- **Bring‑your‑own JSON**: From the home screen you can pick a `.json` file
  from your device and take a quiz based on that file.
- **Null‑safe, layered architecture**: Models, services, screens, and widgets
  are separated for clarity and reuse.

### Project structure

- `lib/main.dart` – App entry point and global theming.
- `lib/models/question.dart` – `Question` model with `fromJson` / `toJson`.
- `lib/services/quiz_service.dart` – Loads questions from bundled assets
  or from a user‑selected JSON file.
- `lib/screens/home_screen.dart` – Landing page with hero card, JSON upload
  area, and buttons to start the default or custom quiz.
- `lib/screens/quiz_screen.dart` – Core quiz flow; shows one question at a time.
- `lib/screens/result_screen.dart` – Score summary screen.
- `lib/widgets/quiz_option_card.dart` – Animated option tiles.
- `lib/widgets/quiz_progress_bar.dart` – Animated quiz progress indicator.
- `assets/quizzes/sample_quiz.json` – Example quiz file.

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

- `flutter`
- `file_picker` – used on the home screen to let users select their own JSON.

### Running the app

From the project root:

```bash
flutter pub get
flutter run
```

### Using your own JSON quiz

1. Launch the app.
2. On the home screen, look for the **"Use your own JSON"** section.
3. Tap **"Choose file"** and select a `.json` file that follows the format
   shown above.
4. The app will parse the file and start a quiz based on those questions.

You can still use the bundled sample quiz via the main **Start Quiz** button. 
