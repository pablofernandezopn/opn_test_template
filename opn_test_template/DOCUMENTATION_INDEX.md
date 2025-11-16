# Flutter Test/Question System - Documentation Index

This directory contains comprehensive documentation for the Flutter quiz/test system in the OPN Guardia Civil app.

## Quick Navigation

### For New Developers
1. Start with **QUICK_REFERENCE.md** (7 min read)
   - Quick lookup of common patterns
   - File location guide
   - Troubleshooting tips

2. Read **ARCHITECTURE_DIAGRAM.txt** (10 min read)
   - Visual component hierarchy
   - Data flow diagrams
   - State management overview

### For Complete Understanding
3. Review **TEST_SYSTEM_DOCUMENTATION.md** (20 min read)
   - Detailed explanation of all 7 system components
   - Code snippets with line references
   - Complete data models
   - Implementation details

## Document Overview

### TEST_SYSTEM_DOCUMENTATION.md (21 KB)
**Comprehensive technical reference**
- Complete system architecture
- All 7 requested system components in depth
- Code snippets with exact line numbers
- Data model definitions
- Special features explanation

**Sections:**
1. Question Page Location & Structure
2. Timer Implementation
3. Test Finalization Flow
4. Results Dialog
5. Navigation Flow
6. State Management
7. Test Configuration

**Best for:** Understanding the complete system, implementation details, code review

---

### ARCHITECTURE_DIAGRAM.txt (20 KB)
**Visual system architecture**
- Component hierarchy tree
- Data flow diagrams
- Timer lifecycle flowchart
- Test finalization step-by-step process
- Results dialog mockups
- Database operation flows

**Sections:**
- Navigation & Routing
- Component Hierarchy
- State Management Structure
- Timer Mechanism
- Test Finalization Flow
- Results Display Options
- Data Models
- Special Features

**Best for:** Understanding relationships, quick visual reference, presentations

---

### QUICK_REFERENCE.md (7.4 KB)
**Quick lookup and practical guide**
- Common code patterns
- Usage examples
- Scoring formula with examples
- Component file reference
- Troubleshooting guide
- Performance tips

**Sections:**
- Main Entry Point
- How to Use TopicTestPage
- Timer Implementation
- Results Calculation
- State Management
- Test Completion Flow
- Results Dialog Actions
- Flashcard Mode
- History Review Mode
- Database Models
- Component Files Quick Lookup
- Common Issues & Solutions

**Best for:** Quick reference during development, troubleshooting, code examples

---

## Key File Locations

### Core Files
| File | Purpose | Lines |
|------|---------|-------|
| `lib/app/features/questions/view/topic_test_page.dart` | Main test page | 1,717 |
| `lib/app/features/questions/cubit/cubit.dart` | State management | 369 |
| `lib/app/features/questions/cubit/state.dart` | State definition | 84 |
| `lib/app/features/questions/repository/repository.dart` | Database access | 188 |

### Component Files
| File | Purpose | Lines |
|------|---------|-------|
| `lib/app/features/questions/view/components/result_summary_sheet.dart` | Results dialog | 474 |
| `lib/app/features/questions/view/components/finish_confirmation_sheet.dart` | Confirmation | 76 |
| `lib/app/features/questions/view/components/flashcard_view.dart` | Flashcards | 512 |
| `lib/app/features/questions/view/components/navigation_controls.dart` | Navigation | 204 |
| `lib/app/features/questions/view/components/question_index_page.dart` | Question index | 150+ |
| `lib/app/features/questions/view/components/after_finish_retro.dart` | Feedback | 150 |

### Model Files
| File | Purpose |
|------|---------|
| `lib/app/features/questions/model/question_model.dart` | Question data |
| `lib/app/features/questions/model/question_option_model.dart` | Option data |
| `lib/app/features/questions/model/user_test_answer_model.dart` | Answer data |

---

## System Overview

### The Test Flow
```
HomePage
  ↓
TopicTestPage (Main container)
  ├─ Initialize: Fetch topic, questions, options, start timer
  ├─ Display: Show PageView with questions
  ├─ Take test: User selects answers, navigates
  ├─ Manage: Track time, record selections, track per-question duration
  ├─ Finalize: Calculate results, save to database
  └─ Show results: Display dialog with options to review, tips, or exit
```

### Core State Management
```
QuestionCubit (Bloc Pattern)
  State: QuestionState (Freezed)
    ├─ questions: List<Question>
    ├─ questionOptions: List<QuestionOption>
    ├─ Various status fields (loading/done/error)
    └─ error: String?
  
  Methods:
    ├─ selectTopic(topicId)
    ├─ fetchQuestions(topicId?, academyId?)
    ├─ loadQuestionsDirectly(questions, options)
    └─ Scoring functions: calculateBlankAnswers, calculateRawScore, etc.
```

### Scoring Formula
```
rawScore = correct - (incorrect * penalty)
finalScore = (rawScore / total) * 10
successRate = (correct / total) * 100

Where:
  penalty = 1 / (options - 1)
  Example: 4 options → penalty = 0.333
```

---

## Feature Highlights

### Flashcard Mode
- Animated flip from front to back
- 4 difficulty ratings: 'again', 'hard', 'medium', 'easy'
- Auto-advance after rating
- Statistics tracking by difficulty

### History Review Mode
- No timer countdown
- Pre-loaded user answers
- Immediate answer revelation
- Read-only mode (locked)
- Tips visible from start

### Tips System
- Unlocked after test completion
- Source: Question.tip field
- Modal bottom sheet display
- Conditional visibility

---

## Database Schema (Relevant Tables)

### UserTest
Stores test-level results
- `id`: Primary key
- `user_id`: User who took test
- `topic_ids`: Array of topic IDs
- `question_count`: Total questions
- `right_questions`: Correct count
- `wrong_questions`: Incorrect count
- `total_answered`: Non-blank count
- `score`: Final score (0-10)
- `finalized`: Test completion flag
- `is_flashcard_mode`: Study mode indicator
- `time_spent_millis`: Actual duration

### UserTestAnswer
Stores per-question responses
- `user_test_id`: FK to UserTest
- `question_id`: FK to Question
- `selected_option_id`: FK to QuestionOption
- `correct`: Was it correct? (nullable)
- `time_taken_seconds`: Time on question
- `question_order`: Question number (1-indexed)
- `difficulty_rating`: Flashcard difficulty

---

## Quick Troubleshooting

| Issue | Check |
|-------|-------|
| Timer not working | topic.durationMinutes > 0, _startTimer() called |
| Results not saving | UserTest.finalized = true, valid userId |
| Questions not loading | fetchQuestionsStatus, topicId, academyId filter |
| Flashcard not flipping | canFlip = true, FlashcardView in flashcard mode |

---

## How to Use These Documents

### Scenario 1: "I need to understand how the test system works"
1. Read QUICK_REFERENCE.md overview (5 min)
2. Review ARCHITECTURE_DIAGRAM.txt diagrams (10 min)
3. Study TEST_SYSTEM_DOCUMENTATION.md sections (20 min)

### Scenario 2: "I need to add a new feature"
1. Check file locations in QUICK_REFERENCE.md
2. Review relevant component in TEST_SYSTEM_DOCUMENTATION.md
3. Look at similar implementations in the codebase

### Scenario 3: "Something is broken, help!"
1. Go to Common Issues & Solutions in QUICK_REFERENCE.md
2. Review relevant flow diagram in ARCHITECTURE_DIAGRAM.txt
3. Check implementation details in TEST_SYSTEM_DOCUMENTATION.md

### Scenario 4: "I need to optimize performance"
1. Review Performance Tips in QUICK_REFERENCE.md
2. Check Timer mechanism in ARCHITECTURE_DIAGRAM.txt
3. Examine _finishTest() optimization opportunities in TEST_SYSTEM_DOCUMENTATION.md

---

## Contact & Updates

These documents were generated on: 2025-11-03

For questions or clarifications, refer to:
- Code comments in topic_test_page.dart
- Cubit methods in cubit.dart
- Repository methods in repository.dart

Generated with comprehensive codebase analysis spanning 3,500+ lines of code across 20+ files.

---

## Document Legend

- **Code Blocks**: Exact code from implementation (with line references)
- **Diagrams**: ASCII art visual representations
- **Tables**: Quick reference information
- **Bold**: Important concepts or keywords
- **File Paths**: Absolute paths from project root

---

Last Updated: 2025-11-03
Scope: Complete test/question system architecture
Coverage: 7/7 requested components (100%)
