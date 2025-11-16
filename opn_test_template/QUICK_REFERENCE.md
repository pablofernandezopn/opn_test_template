# Quick Reference Guide - Test/Question System

## Main Entry Point
**File:** `/lib/app/features/questions/view/topic_test_page.dart`
- **Class:** `TopicTestPage` (StatefulWidget)
- **Lines:** 1,717
- **Key Method:** `_finishTest()` (line 1108) - Handles test completion

## How to Use TopicTestPage

### Basic Navigation
```dart
// Navigate to test page
context.push(
  MaterialPageRoute(
    builder: (_) => TopicTestPage(
      topic: selectedTopic,
      isHistoryReview: false,
    ),
  ),
);
```

### Parameters
| Parameter | Type | Required | Purpose |
|-----------|------|----------|---------|
| `topic` | Topic | Either this or encryptedId | Topic with questions |
| `encryptedId` | String | Either this or topic | Encrypted topic ID |
| `userTest` | UserTest | No | For history review |
| `userTestAnswers` | List<UserTestAnswer> | No | Pre-loaded answers |
| `isHistoryReview` | bool | No | Enable review mode |

## Timer Implementation

### How It Works
```dart
// Timer starts automatically in _prepare()
_startTimer(topic.durationMinutes);

// Updates every 1 second
// Displayed in AppBar as "MM:SS"
// Stored in _remaining: Duration?

// Timer is cancelled on page exit (dispose)
_timer?.cancel();
```

### Key Variables
- `_timer: Timer?` - The actual timer object
- `_remaining: Duration?` - Current remaining time
- `_testStartTime: DateTime?` - When test started
- `_questionStartTime: DateTime?` - When current question started

## Results Calculation

### Scoring Formula
```dart
// 1. Count answers
int correct = 0;
int incorrect = 0;
int blank = totalQuestions - answered;

// 2. Apply penalty
double penalty = topic.options > 1 ? 1 / (topic.options - 1) : 0;
double rawScore = correct - (incorrect * penalty);

// 3. Normalize to 0-10 scale
double finalScore = (rawScore / totalQuestions) * 10;

// 4. Calculate success rate
double successRate = (correct / totalQuestions) * 100;
```

### Penalty Examples
- 2 options: penalty = 1.0 (harsh!)
- 3 options: penalty = 0.5
- 4 options: penalty = 0.33
- 5 options: penalty = 0.25

## State Management

### QuestionCubit
```dart
// Get cubit from context
final cubit = context.read<QuestionCubit>();

// Load questions
cubit.selectTopic(topicId);

// Or pre-load directly (for generated tests)
cubit.loadQuestionsDirectly(
  topicId,
  questionsList,
  optionsList,
  answerDisplayMode: AnswerDisplayMode.atEnd,
);

// Access state
final state = cubit.state;
print(state.questions.length);
print(state.questionOptions.length);
```

## Test Completion Flow

### Step-by-Step Process
1. **User clicks "Finalizar" button** (NavigationControls)
2. **Confirmation dialog appears** (FinishConfirmationSheet)
   - User confirms or cancels
3. **Calculate results** (Lines 1149-1221)
   - Count correct/incorrect/blank
   - Apply penalty
   - Calculate final score
4. **Save to database** (Lines 1247-1301)
   - Insert UserTest record
   - Insert UserTestAnswer records
   - Update UserTest with final results
5. **Update UI** (Lines 1323-1344)
   - Set flags: `_testFinished = true`
   - Save calculated values
   - Unlock tips
6. **Show results dialog** (ResultSummarySheet)
7. **Handle user action**
   - Continue review
   - View tips
   - Exit test

## Results Dialog Actions

### Available Actions
```dart
enum ResultSummaryAction {
  continueReview,  // Stay in review mode
  viewTips,        // Show tips dialog
  exit,            // Exit test and go back
}
```

### Handling Results
```dart
final action = await showResultSummarySheet(
  context: context,
  correct: rightCount,
  incorrect: wrongCount,
  blank: blankCount,
  score: finalScore,
  // ... other required params
);

switch (action) {
  case ResultSummaryAction.continueReview:
    // Show answers in review mode
    break;
  case ResultSummaryAction.viewTips:
    // Display tips dialog
    await _showTipsDialog(questions);
    break;
  case ResultSummaryAction.exit:
    // Navigate away
    Navigator.pop(context);
    break;
}
```

## Flashcard Mode

### Activation
```dart
// Automatically triggered when:
TopicType.level == TopicLevel.Flashcard

// Or manually:
_isFlashcardMode = true;
```

### Features
- Flip animation on card
- Difficulty selection after reveal
- Auto-advance to next card
- Prevents navigation without rating
- Tracks stats per difficulty level

### Difficulty Values
```dart
String difficulty = 'again';   // < 1 day, red
String difficulty = 'hard';    // 1-2 days, orange
String difficulty = 'medium';  // 3-6 days, green
String difficulty = 'easy';    // 7+ days, blue
```

## History Review Mode

### Activation
```dart
TopicTestPage(
  userTest: previousTest,
  userTestAnswers: previousAnswers,
  isHistoryReview: true,
)
```

### Characteristics
- No timer countdown
- All answers pre-loaded and locked
- Correct answers shown immediately
- Tips visible from start
- Test marked as finalized

## Database Models

### Key Fields in UserTest
```dart
UserTest(
  id: int,                    // Primary key
  userId: int,                // Who took the test
  topicIds: [int],            // Which topics
  questionCount: int,         // Total questions
  rightQuestions: int,        // Correct count
  wrongQuestions: int,        // Incorrect count
  totalAnswered: int,         // Non-blank count
  score: double,              // Final score (0-10)
  finalized: bool,            // Test complete?
  isFlashcardMode: bool,      // Flashcard or test?
  minutes: int,               // Allocated time
  timeSpentMillis: int,       // Actual time used
)
```

### Key Fields in UserTestAnswer
```dart
UserTestAnswer(
  userTestId: int,            // Which test
  questionId: int,            // Which question
  selectedOptionId: int?,     // User's choice
  correct: bool?,             // Was it right?
  timeTakenSeconds: int?,     // Time on question
  questionOrder: int,         // Question number
  difficultyRating: String?,  // For flashcards
)
```

## Component Files Quick Lookup

| Purpose | File | Key Class |
|---------|------|-----------|
| Main page | `topic_test_page.dart` | `TopicTestPage` |
| State mgmt | `cubit.dart` | `QuestionCubit` |
| State def | `state.dart` | `QuestionState` |
| Results dialog | `result_summary_sheet.dart` | Function |
| Confirmation | `finish_confirmation_sheet.dart` | Function |
| Flashcards | `flashcard_view.dart` | `FlashcardView` |
| Navigation | `navigation_controls.dart` | `NavigationControls` |
| Question index | `question_index_page.dart` | `QuestionIndexPage` |
| Feedback | `after_finish_retro.dart` | `AfterFinishRetro` |
| Data access | `repository.dart` | `QuestionRepository` |

## Common Issues & Solutions

### Timer Not Working?
- Check if topic.durationMinutes > 0
- Verify _startTimer() is called in _prepare()
- Ensure page is mounted

### Results Not Saving?
- Check UserTest.finalized is set to true
- Verify userId is valid
- Ensure database insert didn't fail

### Questions Not Loading?
- Check QuestionCubit.state.fetchQuestionsStatus
- Verify topicId matches database
- Check academyId filter

### Flashcard Not Flipping?
- Verify canFlip = true
- Check FlashcardView is in flashcard mode
- Ensure options are loaded

## Performance Tips

1. **Use const constructors** where possible
2. **Cancel timers properly** on dispose
3. **Pre-load options** with `fetchAllQuestionOptionsByTopic`
4. **Cache results** to avoid recalculation
5. **Unsubscribe from cubits** in dispose

## Testing Tips

- Mock QuestionCubit and HistoryCubit
- Test scoring formulas separately
- Verify database operations are called
- Check timer increments correctly
- Validate state transitions during finalization

