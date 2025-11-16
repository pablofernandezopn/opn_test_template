# Flutter Quiz/Test System Architecture - OPN Guardia Civil App

## Overview
The test/question system is a comprehensive question answering platform with support for multiple test modes including traditional quizzes and flashcards. The system manages timing, scoring, results, and provides detailed feedback after test completion.

---

## 1. Question Page Location and Structure

### Main Page: `TopicTestPage`
**File:** `/lib/app/features/questions/view/topic_test_page.dart` (1,717 lines)

**Key Responsibilities:**
- Manages the entire test lifecycle (initialization, answering, finalization)
- Handles timer management
- Displays questions using PageView for smooth navigation
- Manages both regular test mode and flashcard mode
- Handles history review mode for previously taken tests

**Page Architecture:**
```
TopicTestPage (StatefulWidget)
├── _TestHeader (AppBar with title, timer, progress)
│   ├── Topic name
│   ├── Current/Total question count
│   └── Countdown timer
├── PageView (Question display)
│   ├── _QuestionPage (Regular test mode)
│   │   ├── Question text
│   │   ├── Question image (if available)
│   │   └── Option tiles (selectable)
│   └── FlashcardView (Flashcard mode)
│       ├── Front card (question)
│       ├── Back card (answer)
│       └── Difficulty rating buttons
├── NavigationControls (Bottom bar)
│   ├── Previous/Next buttons
│   └── Finalizar (Finish) button
└── QuestionActionsBar
    ├── Favorite toggle
    ├── Report/Challenge button
    ├── AI Chat (placeholder)
    └── Share question
```

---

## 2. Timer Implementation

### Timer Management
**Location:** `/lib/app/features/questions/view/topic_test_page.dart` (lines 82-88, 417-439)

**Timer Variables:**
```dart
Timer? _timer;                           // Periodic timer instance
Duration? _remaining;                    // Remaining time
DateTime? _testStartTime;                // Test start timestamp
final Map<int, int> _questionDurationsSeconds = {}; // Per-question tracking
```

**Timer Initialization (Line 417-439):**
```dart
void _startTimer(int minutes) {
  if (minutes <= 0) return;
  
  _remaining = Duration(minutes: minutes);
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) return;
    if (_remaining == null) {
      timer.cancel();
      return;
    }
    final newDuration = _remaining! - const Duration(seconds: 1);
    if (newDuration <= Duration.zero) {
      setState(() {
        _remaining = Duration.zero;
      });
      timer.cancel();
    } else {
      setState(() {
        _remaining = newDuration;
      });
    }
  });
}
```

**Timer Display Format (Line 1384-1386):**
```dart
final timeText = showTimer
    ? '${remaining!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(remaining!.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
    : '';
```
- Format: `MM:SS` (e.g., "15:30")
- Displayed in the AppBar header
- Updates every second

**Per-Question Duration Tracking (Line 942-954):**
```dart
void _recordQuestionDurationForIndex(int index) {
  if (_questionStartTime == null) return;
  final questions = _questionCubit?.state.questions;
  if (questions == null || index < 0 || index >= questions.length) return;
  final question = questions[index];
  final questionId = question.id;
  if (questionId == null) return;
  final elapsedSeconds = DateTime.now().difference(_questionStartTime!).inSeconds;
  if (elapsedSeconds <= 0) return;
  _questionDurationsSeconds[questionId] = 
    (_questionDurationsSeconds[questionId] ?? 0) + elapsedSeconds;
}
```
- Records time spent on each question
- Called when navigating to a new question
- Accumulates total time per question

**Cleanup (Line 111):**
```dart
@override
void dispose() {
  _timer?.cancel();  // Cancel timer on page exit
  _questionSub?.cancel();
  // ...
}
```

---

## 3. Test Finalization Flow

### Flow Diagram
```
User clicks "Finalizar" button
    ↓
_finishTest() called (Line 1108)
    ↓
Show FinishConfirmationSheet (Dialog)
    ├─→ User confirms → Proceed with finalization
    └─→ User cancels → Return to test
    ↓
Record current question duration
    ↓
Calculate test results:
  - Count correct answers
  - Count incorrect answers
  - Count blank answers
  - Calculate raw score (with penalty)
  - Calculate final score (0-10 scale)
  - Calculate success rate percentage
    ↓
Save UserTest to database (history_repository)
    ↓
Save UserTestAnswers for each question
    ↓
Update UserTest with final results
    ↓
Refresh history cubit
    ↓
Show ResultSummarySheet (Results dialog)
```

### Finalization Method (Lines 1108-1353)
**Key Steps:**

1. **Confirmation Dialog** (Lines 1124-1131):
```dart
final confirmation = await showFinishConfirmationSheet(
  context: context, 
  topicType: _topicType
);
if (confirmation != FinishConfirmationAction.finalize) {
  return;  // User cancelled
}
```

2. **Answer Validation** (Lines 1149-1197):
```dart
int right = 0;
int wrong = 0;
int answered = 0;
final pendingAnswers = <Map<String, dynamic>>[];

for (var i = 0; i < questions.length; i++) {
  final question = questions[i];
  final selectedOptionId = _selectedOptions[key];
  
  if (selectedOptionId != null) {
    answered++;
    final option = questionOptions.firstWhere(...);
    if (option.isCorrect) {
      right++;
    } else {
      wrong++;
    }
  }
  
  // Record answer metadata
  pendingAnswers.add({
    'question_id': questionId,
    'selected_option_id': selectedOptionId,
    'correct': isCorrect,
    'time_taken_seconds': durationSeconds,
    'question_order': i + 1,
    'difficulty_rating': difficultyRating,
  });
}
```

3. **Score Calculation** (Lines 1199-1221):
```dart
final blank = cubit.calculateBlankAnswers(
  totalQuestions: totalQuestions,
  answered: answered,
);
final netScore = cubit.calculateRawScore(
  correct: right,
  incorrect: wrong,
  penaltyPerWrong: _topicPenalty,
);
final score = cubit.calculateFinalScore(
  correct: right,
  incorrect: wrong,
  totalQuestions: totalQuestions,
  penaltyPerWrong: _topicPenalty,
);
final successRate = cubit.calculateSuccessRate(
  correct: right,
  totalQuestions: totalQuestions,
);
```

4. **Database Save** (Lines 1247-1301):
```dart
// Create initial UserTest record
final insertedUserTest = await _historyRepository.createUserTest(initialUserTest);

// Insert all answers
final answersModels = pendingAnswers.map(...).toList();
await _historyRepository.insertUserTestAnswers(answersModels);

// Update UserTest with final results
final completedTest = UserTest(
  id: insertedUserTest.id,
  rightQuestions: right,
  wrongQuestions: wrong,
  totalAnswered: answered,
  score: score,
  finalized: true,
  // ... other fields
);
await _historyRepository.updateUserTest(userTestId, completedTest);
```

5. **UI Update & Results Display** (Lines 1323-1344):
```dart
setState(() {
  _tipsUnlocked = true;
  _testFinished = true;
  _resultsSaved = true;
  _savedCorrect = right;
  _savedIncorrect = wrong;
  _savedBlank = blank;
  _savedScore = score;
  _savedNetScore = netScore;
  _savedSuccessRate = successRate;
  _savedHasTips = hasTips;
  _savedFlashcardStats = flashcardStats;
});

await _presentSummary(questionsForTips: questions);
```

---

## 4. Results Dialog

### Result Summary Sheet Component
**File:** `/lib/app/features/questions/view/components/result_summary_sheet.dart` (474 lines)

**Function Signature:**
```dart
Future<ResultSummaryAction?> showResultSummarySheet({
  required BuildContext context,
  required int correct,
  required int incorrect,
  required int blank,
  required double score,
  required double netScore,
  required double successRate,
  required double penalty,
  required bool hasTips,
  required double averageScore,
  TopicType? topicType,
  Map<String, int>? flashcardStats,
})
```

**Results Display - Regular Test Mode:**
```
┌─────────────────────────────────────────┐
│        Resultado del test               │
├─────────────────────────────────────────┤
│                                         │
│         ┌─────────────────┐             │
│         │      10.00      │ (Score)     │
│         └─────────────────┘             │
│                                         │
│  (Optional) ┌───────────────┐           │
│             │  Promedio:    │           │
│             │     9.50      │           │
│             └───────────────┘           │
│                                         │
│  ┌─────────┬─────────┬─────────┐       │
│  │Correct: │Incorrect│En blanco│       │
│  │   15    │   2     │   3     │       │
│  └─────────┴─────────┴─────────┘       │
│                                         │
│  [✓ Continuar revisando]                │
│  [⚠ Ver Tips]                           │
│  [✗ Salir del test]                     │
└─────────────────────────────────────────┘
```

**Flashcard Mode:**
```
┌─────────────────────────────────────────┐
│      Resumen de flashcards              │
├─────────────────────────────────────────┤
│                                         │
│  Has repasado 18 de 20 tarjetas         │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │Otra vez  │  │ Difícil  │            │
│  │ 2 (10%)  │  │ 3 (15%)  │            │
│  └──────────┘  └──────────┘            │
│  ┌──────────┐  ┌──────────┐            │
│  │  Bien    │  │  Fácil   │            │
│  │ 7 (35%)  │  │ 6 (30%)  │            │
│  └──────────┘  └──────────┘            │
│                                         │
│  2 tarjetas pendientes de valorar       │
│                                         │
│  [✓ Continuar revisando]                │
│  [✗ Salir del test]                     │
└─────────────────────────────────────────┘
```

**Result Actions (Enum, Line 5-9):**
```dart
enum ResultSummaryAction {
  continueReview,    // Continue reviewing answers
  viewTips,          // View tips/solutions
  exit,              // Exit test and go home
}
```

**Action Handling (Lines 673-696 in TopicTestPage):**
```dart
switch (resolvedAction) {
  case ResultSummaryAction.continueReview:
    // Return to test in review mode
    break;
  case ResultSummaryAction.viewTips:
    // Show tips dialog
    await _showTipsDialog(questions);
    break;
  case ResultSummaryAction.exit:
    // Exit test
    Navigator.of(context).pop();
    break;
}
```

---

## 5. Navigation Flow

### Complete Navigation Path

```
HomePage (home)
    ↓
[User selects topic or test config]
    ↓
TopicTestPage (topic-test)
├─ Receives parameters:
│  ├─ topic: Topic
│  ├─ encryptedId: String (optional)
│  ├─ userTest: UserTest (for history review)
│  └─ isHistoryReview: bool
│
├─ Initialization (_prepare method):
│  ├─ Fetch Topic details
│  ├─ Validate user permissions (premium check)
│  ├─ Fetch TopicType (for penalty calculation)
│  ├─ Create or get QuestionCubit
│  ├─ Load questions from database
│  └─ Start timer
│
└─ Test Taking:
   ├─ PageView displays questions
   ├─ User selects answers
   ├─ User navigates (prev/next/index)
   ├─ Timer counts down
   │
   ├─ User clicks "Finalizar"
   │  ├─ FinishConfirmationSheet dialog
   │  ├─ Results calculation
   │  ├─ Database save
   │  ├─ ResultSummarySheet dialog
   │  ├─ Show tips (optional)
   │  └─ View results in review mode
   │
   └─ User clicks "Salir"
      └─ Pop back to previous screen
         (HomePage or test config)
```

### Navigation Methods Used

**Navigation via GoRouter:**
```dart
// Navigate to test from topic selection
context.go(AppRoutes.topicTest);

// Navigate home on exit
context.go(AppRoutes.home);

// Push question index page (modal)
Navigator.of(context).push<int>(
  MaterialPageRoute(
    builder: (_) => QuestionIndexPage(...)
  )
);
```

### Routes Configuration
**File:** `/lib/app/config/go_route/app_routes.dart`

```dart
static const String topicTest = '/topic-test';  // Main test page
static const String testConfig = '/test-config'; // Test configuration
static const String test = '/test';              // Active test session
static const String history = '/history';        // Test history
```

---

## 6. State Management

### QuestionCubit (Primary State Management)
**File:** `/lib/app/features/questions/cubit/cubit.dart` (369 lines)

**State Class:** `QuestionState` (immutable with Freezed)
**File:** `/lib/app/features/questions/cubit/state.dart`

**State Properties:**
```dart
@freezed
class QuestionState with _$QuestionState {
  const factory QuestionState({
    @Default([]) List<Question> questions,
    @Default([]) List<QuestionOption> questionOptions,
    int? selectedTopicId,
    int? selectedQuestionId,
    @Default(AnswerDisplayMode.atEnd) AnswerDisplayMode answerDisplayMode,
    required Status fetchQuestionsStatus,
    required Status createQuestionStatus,
    required Status updateQuestionStatus,
    required Status deleteQuestionStatus,
    required Status fetchQuestionOptionsStatus,
    required Status createQuestionOptionStatus,
    required Status updateQuestionOptionStatus,
    required Status deleteQuestionOptionStatus,
    String? error,
  }) = _QuestionState;
}
```

**Cubit Methods (Key for Testing):**

1. **selectTopic** (Lines 25-30):
```dart
void selectTopic(int topicId) async {
  emit(state.copyWith(selectedTopicId: topicId));
  await fetchQuestions(topicId: topicId);
  await fetchAllQuestionOptionsByTopic(topicId);
}
```

2. **fetchQuestions** (Lines 62-82):
```dart
Future<void> fetchQuestions({int? topicId, int? academyId}) async {
  emit(state.copyWith(fetchQuestionsStatus: Status.loading()));
  final questions = await _questionRepository.fetchQuestions(
    topicId: topicId,
    academyId: _currentAcademyId,
  );
  emit(state.copyWith(
    questions: questions,
    fetchQuestionsStatus: Status.done(),
  ));
}
```

3. **loadQuestionsDirectly** (Lines 33-48):
```dart
void loadQuestionsDirectly(
  int virtualTopicId,
  List<Question> questions,
  List<QuestionOption> options, {
  required AnswerDisplayMode answerDisplayMode,
}) {
  emit(state.copyWith(
    selectedTopicId: virtualTopicId,
    questions: questions,
    questionOptions: options,
    answerDisplayMode: answerDisplayMode,
    fetchQuestionsStatus: Status.done(),
    fetchQuestionOptionsStatus: Status.done(),
  ));
}
```

4. **Scoring Methods** (Lines 268-315):
```dart
int calculateBlankAnswers({
  required int totalQuestions,
  required int answered,
})

double calculateRawScore({
  required int correct,
  required int incorrect,
  required double penaltyPerWrong,
})

double calculateFinalScore({
  required int correct,
  required int incorrect,
  required int totalQuestions,
  required double penaltyPerWrong,
  double maxScore = 10,
})

double calculateSuccessRate({
  required int correct,
  required int totalQuestions,
})
```

### Other State Management

**HistoryCubit** (Manages test history)
- Location: `/lib/app/features/history/cubit/history_cubit.dart`
- Refreshed after test completion (Line 1305-1307 in TopicTestPage)

**FavoriteCubit** (Manages favorite questions)
- Location: `/lib/app/features/favorites/cubit/favorite_cubit.dart`
- Used for toggling favorite status (Line 502)

**AuthCubit** (Manages user authentication)
- Location: `/lib/app/authentification/auth/cubit/auth_cubit.dart`
- Used to get current user ID for result saving

---

## 7. Test Configuration

### Configuration Flow
**File:** `/lib/app/features/test_config/view/test_config_page.dart`

**Test Parameters Passed to TopicTestPage:**

1. **Topic** (Required or encryptedId):
```dart
Topic(
  id: int,                          // Topic ID
  topicName: String,                // Display name
  topicTypeId: int,                 // References topic_types table
  durationMinutes: int,             // Timer duration (minutes)
  durationSeconds: double,          // Alternative format
  isPremium: bool,                  // Premium content flag
  options: int,                     // Number of answer options
  averageScore: double,             // User's average score
)
```

2. **TopicType** (Determines mode and penalty):
```dart
TopicType(
  id: int,
  name: String,                     // 'Test', 'Flashcard', etc.
  isTest: bool,                     // Regular test mode
  isFlashcards: bool,               // Flashcard study mode
  level: TopicLevel,                // Mock, Practice, Flashcard
  penalty: double,                  // Penalty per wrong answer
)
```

3. **AnswerDisplayMode** (When to show answers):
```dart
enum AnswerDisplayMode {
  atEnd,           // Show answers after test finishes
  immediate,       // Show answers immediately (review mode)
}
```

### Duration Management
```dart
// Topic configuration
Topic(
  durationMinutes: 60,              // Creates 60-minute timer
  durationSeconds: 3600.0,          // Alternative: 3600 seconds
)

// Timer initialization in TopicTestPage
void _prepare() async {
  _testStartTime = DateTime.now();
  _startTimer(resolvedTopic.durationMinutes);
}

// Timer format in header
'${remaining!.inMinutes.remainder(60)}:${remaining!.inSeconds.remainder(60)}'
```

### Penalty Calculation
```dart
// Default penalty (if TopicType not available)
double _defaultPenaltyForTopic(Topic topic) {
  if (topic.options <= 1) return 0;
  return 1 / (topic.options - 1);
}
// Example: 4 options → 1/3 = 0.333 penalty per wrong

// Used in scoring
double calculateRawScore({
  required int correct,
  required int incorrect,
  required double penaltyPerWrong,
}) {
  return (correct - (incorrect * penaltyPerWrong)).toDouble();
}
```

---

## Key Files Summary

| File | Lines | Purpose |
|------|-------|---------|
| `topic_test_page.dart` | 1,717 | Main test page, timer, finalization |
| `cubit.dart` | 369 | State management for questions |
| `state.dart` | 84 | Question state definition |
| `result_summary_sheet.dart` | 474 | Results dialog component |
| `finish_confirmation_sheet.dart` | 76 | Finalization confirmation dialog |
| `navigation_controls.dart` | 204 | Bottom navigation bar |
| `flashcard_view.dart` | 512 | Flashcard study mode |
| `question_index_page.dart` | 150+ | Question index/overview |
| `after_finish_retro.dart` | 150 | Feedback after answering |
| `repository.dart` | 188 | Database access for questions |

---

## Data Models

### Question
```dart
class Question {
  final int? id;
  final String question;
  final String? tip;
  final int topic;
  final String? article;
  final String questionImageUrl;
  final String retroImageUrl;
  final bool retroAudioEnable;
  final String retroAudioText;
  final int order;
  final bool published;
  final bool? shuffled;
  final int numAnswered;
  final int numFails;
  final int numEmpty;
  final double? difficultRate;
  final DateTime? createdAt;
  final String? createdBy;
  final bool challengeByTutor;
  final String? challengeReason;
  final int academyId;
}
```

### QuestionOption
```dart
class QuestionOption {
  final int? id;
  final int questionId;
  final String answer;
  final bool isCorrect;
  final int optionOrder;
  // ... other fields
}
```

### UserTest (Results Storage)
```dart
class UserTest {
  final int? id;
  final int userId;
  final List<int> topicIds;
  final int options;
  final int questionCount;
  final int? rightQuestions;
  final int? wrongQuestions;
  final int? totalAnswered;
  final double? score;
  final bool finalized;
  final int minutes;
  final int? timeSpentMillis;
  final bool isFlashcardMode;
  // ... other fields
}
```

---

## Special Features

### Flashcard Mode
- **Activation:** TopicLevel.Flashcard triggers flashcard UI
- **Components:** FlashcardView with flip animation
- **Difficulty Ratings:** 'again', 'hard', 'medium', 'easy'
- **Auto-advance:** Automatically moves to next card after difficulty selection
- **Stats Tracking:** Counts cards by difficulty rating

### History Review Mode
- **Activation:** `isHistoryReview = true` parameter
- **Features:**
  - Disables timer
  - Shows all answers immediately
  - Pre-loads user's previous answers
  - Allows reviewing submitted test

### Tips System
- **Visibility:** Unlocked after test completion
- **Content:** From Question.tip field
- **Display:** Modal bottom sheet with all tips
- **Condition:** Only shown if questions have tips

