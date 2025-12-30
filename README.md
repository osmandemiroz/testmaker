<div align="center">

# 📚 TestMaker

### *Transform PDFs into Interactive Learning Experiences with AI*

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.6.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.6.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS-lightgrey?style=for-the-badge" alt="Platform"/>
</p>

<p align="center">
  <strong>A modern Flutter quiz & flashcard application with AI-powered content generation</strong>
</p>

<p align="center">
  Beautiful • Intuitive • Powerful
</p>

[Features](#-features) • [Quick Start](#-quick-start) • [Usage](#-usage-guide) • [Architecture](#-architecture)

---

</div>

## ✨ Overview

**TestMaker** revolutionizes how you create and study with quizzes and flashcards. Upload any PDF document and watch as Google Gemini AI automatically transforms it into interactive learning materials. With a beautiful Apple-inspired interface featuring smooth animations, parallax effects, and intuitive gestures, studying has never been more engaging.

<div align="center">

### 🎯 Why TestMaker?

</div>

<table>
<tr>
<td width="33%" align="center">

#### 🤖 AI-Powered
Automatically generate quizzes and flashcards from your PDFs using Google Gemini AI

</td>
<td width="33%" align="center">

#### 🎨 Beautiful Design
Apple-inspired UI with smooth animations, parallax effects, and intuitive gestures

</td>
<td width="33%" align="center">

#### 📊 Track Progress
Monitor your learning with detailed analytics and performance charts

</td>
</tr>
</table>

---

## 🚀 Key Features

<details open>
<summary><strong>🔐 Firebase Authentication</strong></summary>
<br>

- **Email/Password Login** - Traditional authentication with secure password handling
- **Google Sign-In** - One-tap authentication with Google account
- **Apple Sign-In** - Native Apple authentication on iOS devices
- **Guest Mode** - Continue without account, upgrade anytime
- **Password Recovery** - Forgot password with email reset
- **Account Linking** - Upgrade guest accounts to full accounts

</details>

<details open>
<summary><strong>🎬 First Launch Experience</strong></summary>
<br>

- **Animated Onboarding** - Beautiful 4-screen introduction with parallax effects
- **Breathing Logo Animation** - Eye-catching app logo with dynamic glow effects
- **Interactive Demonstrations** - 3D flip animations and visual feature showcases
- **Skip Anytime** - User-controlled onboarding with persistent state management

</details>

<details open>
<summary><strong>🤖 AI-Powered Generation</strong></summary>
<br>

- **Smart Quiz Creation** - Generate questions automatically from PDF content
- **Intelligent Flashcards** - Create flashcard sets with AI assistance
- **Google Gemini Integration** - Powered by cutting-edge AI technology
- **Customizable Output** - Choose number of questions/flashcards to generate

</details>

<details open>
<summary><strong>📚 Content Management</strong></summary>
<br>

- **Course Organization** - Group quizzes, flashcards, and PDFs into courses
- **Sidebar Navigation** - Easy access to all your study materials
- **Text-Based Input** - Paste content directly, no JSON files needed
- **PDF Integration** - Upload, view, and study from PDF documents
- **Content Templates** - Ready-made prompts for AI content generation

</details>

<details open>
<summary><strong>🎓 Learning Experience</strong></summary>
<br>

- **Interactive Quizzes** - Randomized questions and options for authentic testing
- **3D Flip Flashcards** - Swipeable cards with smooth animations
- **Progress Tracking** - Detailed analytics with performance charts
- **Result Summaries** - Instant feedback with score breakdowns
- **Custom Naming** - Organize content with personalized names

</details>

<details open>
<summary><strong>⚡ Performance & Design</strong></summary>
<br>

- **Smooth 60fps** - Optimized animations and scrolling
- **Responsive Layout** - Adapts to mobile, tablet, and desktop screens
- **Offline Support** - All data stored locally, works without internet
- **Apple HIG Compliant** - Following iOS design principles
- **Clean Architecture** - MVC pattern with modular components

</details>

---

## 🎬 Onboarding Experience

<div align="center">

### *Welcome to TestMaker*

</div>

First-time users are greeted with a stunning **4-screen onboarding flow** showcasing the app's capabilities:

<table>
<tr>
<td width="25%" align="center">

### 1️⃣

**Welcome**

🎓

App logo with breathing animation and introduction to TestMaker

</td>
<td width="25%" align="center">

### 2️⃣

**AI Quizzes**

🤖

PDF to quiz transformation with arrow animations

</td>
<td width="25%" align="center">

### 3️⃣

**Flashcards**

🎴

3D flip animation demonstrating card interaction

</td>
<td width="25%" align="center">

### 4️⃣

**Analytics**

📊

Progress tracking and course organization

</td>
</tr>
</table>

### Animation Features

- **Parallax Scrolling** - Multi-layered depth effects
- **Breathing Effects** - Logo scales and glows (3-second cycle)
- **3D Transformations** - Perspective-based flip animations
- **Smart Optimization** - Animations pause when off-screen for better performance
- **Responsive Design** - Scales perfectly across all devices

---

## 📱 App Screens

<div align="center">

### Key Screens & Features

</div>

<table>
<tr>
<td width="33%" align="center">

### 🔐 Auth Screen

**Sign In Options**
- Email/Password form
- Google Sign-In button
- Apple Sign-In (iOS)
- Continue as Guest

**Features**
- Toggle Login/Register
- Password visibility
- Forgot password link
- Form validation

</td>
<td width="33%" align="center">

### 🏠 Home Screen

**Sidebar Navigation**
- Course list with icons
- Create/delete courses
- Quick access menu
- Swipe indicator for drawer

**Main Content**
- Module cards with expansion
- Empty states with guidance
- Floating action button menu

</td>
<td width="33%" align="center">

### 📝 Quiz Screen

**Interactive Testing**
- Question cards with animations
- Multiple choice options
- Progress bar indicator
- Randomized questions
- Timer (optional)

**Navigation**
- Next/Previous buttons
- Question counter
- Exit confirmation

</td>
</tr>
<tr>
<td width="33%" align="center">

### 📊 Analytics Screen

**Performance Tracking**
- Summary statistics
- Bar chart visualization
- Average score display
- Best performing quiz
- Recent activity list

**Insights**
- Course-specific analytics
- Quiz comparison
- Progress over time

</td>
<td width="33%" align="center">

### 🎴 Flashcard Screen

**Study Interface**
- 3D flip animations
- Swipe navigation
- Card counter
- Front/back content
- Explanation text

**Controls**
- Tap to flip
- Swipe left/right
- Shuffle option
- Progress indicator

</td>
<td width="33%" align="center">

### 📄 PDF Viewer

**Document Viewing**
- Full-screen PDF display
- Page navigation
- Zoom controls
- Page counter

**Actions**
- Generate questions
- Generate flashcards
- Close viewer
- Scroll navigation

</td>
<td width="33%" align="center">

### 📚 Course View

**Content Organization**
- PDF cards with previews
- Quiz cards with counts
- Flashcard set cards
- Expandable actions

**Management**
- Rename items
- Delete with swipe
- Reorder content
- Add new materials

</td>
</tr>
</table>

---

## 🏃 Quick Start

### Prerequisites

- Flutter SDK `>=3.6.1 <4.0.0`
- Dart SDK `>=3.6.1 <4.0.0`
- Firebase project (for authentication)
- Google Gemini API key (for AI features)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/osmandemiroz/testmaker.git
cd testmaker

# 2. Set up environment variables
cp .env.example .env
# Edit .env with your Firebase API keys (see Environment Setup below)

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### 🔧 Environment Setup

This project uses environment variables to securely store Firebase API keys.

**Step 1:** Copy the example environment file:
```bash
cp .env.example .env
```

**Step 2:** Get your Firebase configuration:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → Project Settings → General
3. Scroll to "Your apps" section
4. Copy the configuration values

**Step 3:** Fill in your `.env` file:
```env
# Android Firebase Config
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_ANDROID_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_ANDROID_PROJECT_ID=your_project_id
FIREBASE_ANDROID_STORAGE_BUCKET=your_storage_bucket

# iOS Firebase Config
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_IOS_PROJECT_ID=your_project_id
FIREBASE_IOS_STORAGE_BUCKET=your_storage_bucket
FIREBASE_IOS_CLIENT_ID=your_ios_client_id
FIREBASE_IOS_BUNDLE_ID=your_bundle_id
```

> ⚠️ **Important**: Never commit your `.env` file to version control!

### 🔥 Firebase Setup

**Enable Authentication Methods:**
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable the following providers:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Apple (iOS only)

### 🎬 First Launch

On your first launch, enjoy the **animated onboarding experience**:

1. ✨ **Welcome Screen** - Meet TestMaker with breathing logo animation
2. 🤖 **AI Quiz Generation** - Learn how PDFs become interactive quizzes
3. 🎴 **Smart Flashcards** - Discover 3D flip flashcard creation
4. 📊 **Progress Tracking** - Explore analytics and organization features

**Skip anytime** or **swipe through** to start learning!

### 🎯 Getting Started

After onboarding:

1. **Create a Course** → Tap "New Course" button
2. **Add Content** → Upload PDF or paste quiz/flashcard content
3. **Start Learning** → Take quizzes, study flashcards
4. **Track Progress** → View analytics in the Analytics tab

---

## 📖 Usage Guide

<details>
<summary><h3>🔐 Authentication</h3></summary>

#### Sign In Options

| Method | Description |
|--------|-------------|
| **Email/Password** | Create account or sign in with email |
| **Google** | One-tap sign in with Google account |
| **Apple** | Sign in with Apple ID (iOS only) |
| **Guest** | Continue without account |

#### Account Features

```
• Create Account → Enter name, email, password
• Sign In → Enter email and password
• Forgot Password → Enter email to receive reset link
• Guest Mode → Explore app, upgrade account later
• Sign Out → Available in settings
```

#### Upgrading Guest Account

Guest users can upgrade to a full account anytime:
1. Go to Settings
2. Tap "Upgrade Account"
3. Choose Google or Apple sign-in
4. Your data will be preserved!

> 🔒 **Security**: All authentication is handled by Firebase with industry-standard encryption.

</details>

<details>
<summary><h3>📝 Adding Quizzes & Flashcards</h3></summary>

#### Method 1: Direct Text Input (Recommended)

```
1. Select a course
2. Tap FAB (Floating Action Button) → bottom-right
3. Choose "Upload Quiz" or "Upload Flashcards"
4. Paste content → App auto-parses it
```

**Supported Formats:**

**Quiz (JSON):**
```json
[
  {
    "id": 1,
    "text": "What language is Flutter built with?",
    "options": ["Java", "Swift", "Dart", "Kotlin"],
    "answerIndex": 2
  }
]
```

**Flashcard (JSON):**
```json
[
  {
    "id": 1,
    "front": "What is Flutter?",
    "back": "UI toolkit for building natively compiled applications",
    "explanation": "Flutter uses Dart and compiles to native code"
  }
]
```

#### Method 2: AI Generation

```
1. Upload a PDF to a course
2. Tap "Generate Questions" or "Generate Flashcards"
3. Choose quantity (5-20 questions, 10-30 flashcards)
4. Enter Google Gemini API key (first time only)
5. Wait for AI to generate content
```

#### Method 3: Content Templates

```
1. Scroll to "Content Templates" section
2. Select "Quiz" or "Flashcard" template
3. Choose type and count
4. Copy generated prompt
5. Use with ChatGPT/Claude/other AI
6. Paste generated content back
```

</details>

<details>
<summary><h3>🗂️ Course Management</h3></summary>

| Action | Steps |
|--------|-------|
| **Create Course** | Sidebar → "New Course" → Enter name |
| **Add Quiz** | Select course → FAB → "Upload Quiz" → Paste content |
| **Add Flashcards** | Select course → FAB → "Upload Flashcards" → Paste content |
| **Upload PDF** | Select course → FAB → "Upload PDF" → Choose file |
| **View PDF** | Tap PDF card |
| **Start Quiz** | Tap quiz card (questions randomized) |
| **Study Flashcards** | Tap flashcard set → Swipe to navigate, tap to flip |
| **View Analytics** | Select course → "Analytics" tab |
| **Rename Item** | Long-press any card → Enter new name |
| **Delete Item** | Swipe left → Confirm deletion |

</details>

<details>
<summary><h3>📊 Analytics & Progress Tracking</h3></summary>

**Features:**
- 📈 **Performance by Quiz** - See which quizzes you excel at
- 📊 **Average Score Tracking** - Monitor overall performance
- ⭐ **Best Performing Quiz** - Identify strongest areas
- 📅 **Recent Activity** - Review recent attempts with dates
- 💾 **Automatic Tracking** - All results saved automatically

**How to View:**
```
1. Select a course from sidebar/modules
2. Tap "Analytics" tab
3. View:
   • Summary statistics
   • Performance chart
   • Recent activity list
```

> 💡 **Tip**: Take quizzes multiple times to see improvement over time!

</details>

<details>
<summary><h3>🤖 AI-Powered Generation</h3></summary>

#### Quiz Generation

```
1. Upload PDF to course
2. Tap "Generate Questions" below PDF card
3. Enter question count (recommended: 5-20)
4. Enter API key (first time):
   • Get free key: https://makersuite.google.com/app/apikey
5. Wait for generation
6. Quiz automatically added to course
```

#### Flashcard Generation

```
1. Upload PDF to course
2. Tap "Generate Flashcards" below PDF card
3. Enter flashcard count (recommended: 10-30)
4. Enter API key (if not set)
5. Wait for generation
6. Flashcard set automatically added
```

**Important Notes:**
- ⚠️ Extracts text from first 10 pages (performance optimization)
- ⚠️ Best with text-based PDFs (not scanned images)
- ⚠️ Internet required for generation
- ✅ Generated content works offline after creation
- ✅ API key stored locally (never uploaded)

</details>

---

## 🔑 API Key Setup

<div align="center">

### Google Gemini AI Integration

</div>

TestMaker uses **Google Gemini** for intelligent content generation.

**Setup Steps:**

1. **Get API Key** → Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. **Trigger Generation** → Tap "Generate Questions" or "Generate Flashcards"
3. **Enter Key** → Paste when prompted (stored locally)
4. **Start Generating** → Create unlimited content!

> 🔒 **Security**: Your API key is stored locally on your device and **never** uploaded to external servers.

---

## 💾 Data Storage

<div align="center">

### Everything Stored Locally

</div>

<table>
<tr>
<td width="25%" align="center">

📚 **Courses**

SharedPreferences

</td>
<td width="25%" align="center">

📄 **PDFs**

Documents Directory

</td>
<td width="25%" align="center">

📊 **Results**

SharedPreferences

</td>
<td width="25%" align="center">

⚙️ **Settings**

SharedPreferences

</td>
</tr>
</table>

**Benefits:**
- ✅ Works completely offline (except AI generation)
- ✅ Data persists across app restarts
- ✅ Fast access to all content
- ✅ Privacy-focused (no cloud storage)

> 🌐 **Note**: Internet only required for AI quiz and flashcard generation

---

## 🏗️ Architecture

<div align="center">

### Clean MVC Architecture

</div>

```
┌─────────────────────────────────────────────────────────────┐
│                          VIEWS                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Home       │  │   Quiz       │  │  Flashcard   │     │
│  │   Screen     │  │   Screen     │  │   Screen     │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼────────────┐
│         ▼                  ▼                  ▼             │
│                     CONTROLLERS                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Home       │  │   Quiz       │  │  Flashcard   │     │
│  │ Controller   │  │ Controller   │  │ Controller   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼────────────┐
│         ▼                  ▼                  ▼             │
│                      SERVICES                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Course     │  │   Quiz       │  │  Flashcard   │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
    ┌─────────────────────────────────────────────┐
    │              MODELS & DATA                  │
    │  Course • Question • Flashcard • Result     │
    └─────────────────────────────────────────────┘
```

### 📁 Project Structure

<details>
<summary><strong>Click to expand full structure</strong></summary>

```
lib/
├── 📱 main.dart                    # Entry point with Firebase & env loading
├── 🔥 firebase_options.dart        # Firebase config (from env vars)
│
├── 🎨 theme/
│   └── app_theme.dart              # Light/dark themes (Apple HIG)
│
├── 📦 models/
│   ├── app_user.dart               # Authenticated user model
│   ├── question.dart               # Quiz question model
│   ├── flashcard.dart              # Flashcard model
│   ├── course.dart                 # Course organization model
│   └── quiz_result.dart            # Result tracking model
│
├── 🎮 controllers/
│   ├── auth_controller.dart        # Authentication state management
│   ├── home_controller.dart        # Course management logic
│   ├── quiz_controller.dart        # Quiz state management
│   ├── flashcard_controller.dart   # Flashcard state management
│   └── analytics_controller.dart   # Analytics data aggregation
│
├── ⚙️ services/
│   ├── auth_service.dart           # Firebase auth operations
│   ├── quiz_service.dart           # Quiz data operations
│   ├── flashcard_service.dart      # Flashcard data operations
│   ├── course_service.dart         # Course CRUD operations
│   ├── onboarding_service.dart     # First-launch state management
│   ├── pdf_text_extractor.dart     # PDF text extraction
│   ├── question_generator_service.dart  # AI quiz generation
│   ├── flashcard_generator_service.dart # AI flashcard generation
│   └── quiz_result_service.dart    # Result persistence
│
├── 📺 screens/
│   ├── home_screen.dart            # Main screen (refactored)
│   ├── quiz_screen.dart            # Quiz interface
│   ├── flashcard_screen.dart       # Flashcard viewer
│   ├── result_screen.dart          # Score summary
│   ├── pdf_viewer_screen.dart      # PDF viewer
│   ├── analytics_screen.dart       # Analytics dashboard
│   │
│   ├── 🔐 auth/                    # Authentication screens
│   │   ├── auth_screen.dart             # Login/Register screen
│   │   └── widgets/                     # Auth UI components
│   │       ├── auth_text_field.dart     # Styled text inputs
│   │       ├── auth_primary_button.dart # Primary action button
│   │       ├── social_sign_in_button.dart # Google/Apple buttons
│   │       ├── guest_button.dart        # Continue as guest
│   │       └── auth_divider.dart        # "or" divider
│   │
│   ├── 🎬 onboarding/              # Onboarding flow
│   │   ├── onboarding_screen.dart       # Main PageView screen
│   │   ├── onboarding_page.dart         # Individual pages
│   │   ├── onboarding_content.dart      # Page content models
│   │   ├── decorative_elements.dart     # Parallax decorations
│   │   └── onboarding.dart              # Barrel exports
│   │
│   └── 🏠 home/                    # Modular home components
│       ├── 💬 dialogs/             # Dialog components
│       │   ├── api_key_dialog.dart
│       │   ├── create_course_dialog.dart
│       │   ├── delete_confirmation_dialogs.dart
│       │   └── ... (9 more dialogs)
│       │
│       ├── 🎯 handlers/            # Business logic handlers
│       │   ├── content_add_handlers.dart
│       │   ├── course_management_handlers.dart
│       │   ├── delete_handlers.dart
│       │   └── ... (3 more handlers)
│       │
│       ├── 📋 items/               # Reusable item components
│       │   ├── course_item.dart
│       │   ├── quiz_card.dart
│       │   ├── flashcard_card.dart
│       │   └── ... (4 more items)
│       │
│       ├── 📐 views/               # View components
│       │   ├── sidebar.dart
│       │   ├── modules_view.dart
│       │   ├── course_content_view.dart
│       │   └── ... (5 more views)
│       │
│       ├── 🎨 widgets/             # Custom widgets
│       │   ├── fab_menu.dart
│       │   ├── animated_action_button.dart
│       │   └── ... (2 more widgets)
│       │
│       └── 📝 templates/           # Content templates
│           ├── content_templates_section.dart
│           └── prompt_generator.dart
│
├── 🧩 widgets/
│   ├── quiz_option_card.dart       # Quiz option UI
│   ├── quiz_progress_bar.dart      # Progress indicator
│   └── parallax_layer.dart         # Parallax animations
│
└── 🛠️ utils/
    └── responsive_sizer.dart       # Responsive sizing utility
```

</details>

---

## 📦 Dependencies

<table>
<tr>
<th>Package</th>
<th>Purpose</th>
<th>Version</th>
</tr>
<tr>
<td><code>flutter</code></td>
<td>Framework</td>
<td>SDK</td>
</tr>
<tr>
<td colspan="3"><strong>🔐 Authentication</strong></td>
</tr>
<tr>
<td><code>firebase_core</code></td>
<td>Firebase initialization</td>
<td>^3.8.1</td>
</tr>
<tr>
<td><code>firebase_auth</code></td>
<td>Firebase authentication</td>
<td>^5.3.4</td>
</tr>
<tr>
<td><code>google_sign_in</code></td>
<td>Google OAuth login</td>
<td>^6.2.2</td>
</tr>
<tr>
<td><code>sign_in_with_apple</code></td>
<td>Apple Sign-In (iOS)</td>
<td>^6.1.4</td>
</tr>
<tr>
<td><code>flutter_dotenv</code></td>
<td>Environment variables</td>
<td>^5.2.1</td>
</tr>
<tr>
<td colspan="3"><strong>📚 Content & Storage</strong></td>
</tr>
<tr>
<td><code>file_picker</code></td>
<td>File selection</td>
<td>^8.1.5</td>
</tr>
<tr>
<td><code>shared_preferences</code></td>
<td>Local storage</td>
<td>^2.3.3</td>
</tr>
<tr>
<td><code>path_provider</code></td>
<td>File paths</td>
<td>^2.1.4</td>
</tr>
<tr>
<td><code>syncfusion_flutter_pdf</code></td>
<td>PDF text extraction</td>
<td>^28.2.8</td>
</tr>
<tr>
<td><code>syncfusion_flutter_pdfviewer</code></td>
<td>PDF viewing</td>
<td>^28.2.8</td>
</tr>
<tr>
<td colspan="3"><strong>🎨 UI & Utilities</strong></td>
</tr>
<tr>
<td><code>flutter_svg</code></td>
<td>SVG rendering</td>
<td>^2.0.10</td>
</tr>
<tr>
<td><code>http</code></td>
<td>API calls</td>
<td>^1.2.2</td>
</tr>
<tr>
<td><code>url_launcher</code></td>
<td>External URLs</td>
<td>^6.3.1</td>
</tr>
<tr>
<td><code>deriv_chart</code></td>
<td>Analytics charts</td>
<td>^0.4.1</td>
</tr>
<tr>
<td><code>crypto</code></td>
<td>Cryptographic functions</td>
<td>^3.0.6</td>
</tr>
</table>

---

## 🔒 Security

<div align="center">

### Secure by Design

</div>

| Feature | Implementation |
|---------|---------------|
| **API Keys** | Stored in `.env` file (never committed) |
| **Firebase Config** | Loaded from environment variables |
| **Authentication** | Firebase Auth with industry encryption |
| **Password Storage** | Handled by Firebase (never stored locally) |
| **Guest Sessions** | Anonymous Firebase accounts |

**Protected Files (in `.gitignore`):**
```
.env                              # Your API keys
lib/firebase_options.dart         # Firebase configuration
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

> 🔐 **Note**: When cloning, you must create your own `.env` file from `.env.example`

---

## 🔄 Recent Updates

### 🔐 Firebase Authentication (December 2024)

<table>
<tr>
<td width="50%">

**Features Added:**
- ✅ Email/Password authentication
- ✅ Google Sign-In integration
- ✅ Apple Sign-In (iOS)
- ✅ Guest mode with account upgrade
- ✅ Password reset via email
- ✅ Secure environment variables

</td>
<td width="50%">

**Security Improvements:**
- 🔒 API keys moved to `.env` file
- 🔒 Firebase config from environment
- 🔒 Sensitive files in `.gitignore`
- 🔒 `.env.example` template for devs
- 🔒 No hardcoded secrets in code

</td>
</tr>
</table>

### 🎬 Onboarding System (December 2024)

<table>
<tr>
<td width="50%">

**Features Added:**
- ✨ 4-screen animated onboarding flow
- 🎨 Parallax scrolling effects
- 🎭 Logo breathing animation with glow
- 🔄 3D flip flashcard demonstration
- ⏭️ Skip functionality with state persistence
- 📱 Fully responsive design

</td>
<td width="50%">

**Performance Optimizations:**
- ⚡ 60fps smooth scrolling
- 🎯 50% shadow complexity reduction
- 🔋 Smart animation pausing (off-screen)
- 🖼️ Image caching with size constraints
- 🎨 Optimized gradient rendering
- 🚫 IgnorePointer on decorative elements

</td>
</tr>
</table>

### 🏗️ Code Refactoring (2024)

**Home Screen Modularization:**
- 📊 **Before**: ~1,087 lines
- 📊 **After**: ~429 lines
- 📉 **Reduction**: 61% (658 lines)
- 📦 **Components**: 30+ reusable components
- 🎯 **Handlers**: 6 dedicated handler classes

**Benefits:**
- ✅ Improved maintainability
- ✅ Better code reusability
- ✅ Easier testing
- ✅ Enhanced readability
- ✅ Reduced complexity

---

## 🛠️ Development

### Build Commands

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release

# Desktop
flutter build macos --release  # macOS
flutter build windows          # Windows
flutter build linux            # Linux
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to branch (`git push origin feature/amazing-feature`)
5. 🔃 Open a Pull Request

### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Write comprehensive comments
- Maintain the existing architecture
- Test your changes
- Update documentation

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 TestMaker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

See the [LICENSE](LICENSE) file for full details.

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Firebase** - Authentication and backend services
- **Google Gemini** - AI-powered content generation
- **Syncfusion** - PDF viewing and text extraction
- **Community** - For inspiration and support

---

<div align="center">

## 💬 Contact & Support

<p>
  <a href="https://github.com/osmandemiroz/testmaker/issues">
    <img src="https://img.shields.io/badge/Report%20Bug-GitHub%20Issues-red?style=for-the-badge" alt="Report Bug"/>
  </a>
  <a href="https://github.com/osmandemiroz/testmaker/discussions">
    <img src="https://img.shields.io/badge/Discussions-GitHub-blue?style=for-the-badge" alt="Discussions"/>
  </a>
</p>

---

### Made with ❤️ using Flutter

*Designed following Apple's Human Interface Guidelines*

**Clean • Minimal • Delightful**

---

<p>
  <a href="#-testmaker">⬆ Back to Top</a>
</p>

**TestMaker** © 2024

</div>
