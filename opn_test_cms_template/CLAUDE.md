# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OPN Test Guardia Civil CMS** is a Custom Management System Flutter application for Spanish Guardia Civil exam preparation. The app integrates with Supabase for backend services, WordPress RCP for content management, and RevenueCat for in-app purchases and subscriptions.

**Tech Stack:**
- Flutter 3.35.6 / Dart 3.9.2
- Supabase (PostgreSQL, Edge Functions, Auth)
- Firebase (FCM, In-App Messaging)
- RevenueCat (IAP management)
- WordPress RCP (Content/membership source)

## Development Commands

### Running the Application

```bash
# Development (local Supabase)
flutter run

# Development with custom local IP (for physical devices)
flutter run --dart-define=LOCAL_IP=192.168.1.100

# Build for production
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
```

### Code Generation

This project uses `freezed` and `json_serializable` for code generation:

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing & Analysis

```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

### Supabase Local Development

```bash
# Start Supabase local (from ../supabase directory)
cd ../supabase
supabase start

# Stop Supabase
supabase stop

# View Supabase status
docker ps | grep supabase

# View Edge Function logs
docker logs -f supabase_edge_runtime_opn_gc_test

# Connect to local PostgreSQL
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Create new migration
supabase migration new description_of_change

# Apply migrations
supabase db push
```

### Supabase Production Deployment

```bash
# Login to Supabase
supabase login

# Link to production project
supabase link --project-ref your-project-ref

# Deploy Edge Functions
supabase functions deploy login-register

# Set production secrets
supabase secrets set WP_URL=https://your-wordpress.com
supabase secrets set WP_ADMIN_USERNAME=your-username
# ... etc

# View logs in production
supabase functions logs login-register --follow
```

## Architecture

### High-Level Structure

The app follows a **feature-first architecture** with BLoC pattern for state management:

```
lib/
├── app/                              # Application layer
│   ├── authentification/             # Auth feature
│   │   ├── auth/                     # Auth state management
│   │   │   ├── cubit/               # AuthCubit (global auth state)
│   │   │   ├── model/               # User, UserMembership models
│   │   │   └── repository/          # AuthRepository (Supabase)
│   │   ├── signinup/                # Sign-in/Sign-up UI
│   │   └── success/                 # Success page after auth
│   ├── features/                     # App features
│   │   └── topics/                  # Topics/content management
│   │       ├── cubit/               # TopicCubit (state)
│   │       ├── model/               # Topic models
│   │       ├── repository/          # TopicRepository
│   │       └── view/                # Topic pages/UI
│   ├── config/                      # App-wide configuration
│   │   ├── go_route/               # Navigation system (GoRouter)
│   │   ├── layout/                 # App layout (sidebar, menu)
│   │   ├── theme/                  # Theme system (colors, text, buttons)
│   │   ├── widgets/                # Reusable widgets
│   │   ├── app_bloc_providers.dart # BLoC providers setup
│   │   ├── app_bloc_listeners.dart # Global BLoC listeners
│   │   ├── preferences_service.dart # SharedPreferences wrapper
│   │   └── service_locator.dart    # GetIt DI setup
│   └── app.dart                     # Root MyApp widget
├── config/                          # Environment configuration
│   ├── environment.dart            # Environment variables (dev/staging/prod)
│   ├── app_texts.dart              # App text constants
│   └── device_info.dart            # Device info utilities
├── bootstrap.dart                   # App initialization/bootstrap
└── main.dart                        # Entry point
```

### Key Architectural Patterns

**1. BLoC Pattern (Business Logic Component)**
- All features use Cubits (simplified BLoC) for state management
- State classes use `freezed` for immutability and unions
- Repositories handle data layer, Cubits handle business logic
- Example: `AuthCubit` manages global authentication state

**2. Dependency Injection (GetIt)**
- Service locator pattern via `GetIt`
- All services/repositories registered in `service_locator.dart`
- Access via `getIt<ServiceName>()`

**3. Repository Pattern**
- Each feature has a repository (e.g., `AuthRepository`, `TopicRepository`)
- Repositories abstract Supabase/API calls
- Cubits depend on repositories, never direct API calls

**4. Navigation (GoRouter)**
- Declarative routing with `go_router` package
- Routes defined in `app/config/go_route/app_routes.dart`
- Router configuration in `app_router.dart`
- Deep linking support for Android/iOS/Web
- See `lib/app/config/go_route/README.md` for detailed navigation guide

**5. Theme System**
- Centralized theme in `app/config/theme/`
- Separate files for colors, text, buttons, inputs, components
- Light/dark mode support via `AppLayoutCubit`
- See `lib/app/config/theme/README.md` for theme usage

### Authentication Flow

1. User enters credentials in `SignInPage`
2. `SignInCubit` calls `AuthRepository.signIn()`
3. `AuthRepository` authenticates with Supabase Auth
4. On success, fetches user data from `cms_users` table
5. Returns `CmsUser` with memberships and token
6. `AuthCubit` updates global auth state
7. Router redirects based on auth state

**Important:** The app uses TWO user models:
- Supabase Auth User (authentication)
- `CmsUser` (application user data from `cms_users` table)

### Supabase Integration

**Local Development:**
- Supabase runs locally via Docker (port 54321)
- Default IP: `127.0.0.1` (iOS simulator) or `10.0.2.2` (Android emulator)
- For physical devices, set IP via `--dart-define=LOCAL_IP=your_ip`
- Configuration in `config/environment.dart` (BuildVariant.development)

**Database Schema:**
- `cms_users` - Application users (linked to Supabase auth.users via user_uuid)
- `membership_levels` - Available membership tiers (synced from WordPress RCP)
- `user_memberships` - User's active memberships (synced from WordPress & RevenueCat)
- `profiles` - User profiles (extended user data)
- See `../supabase/docs/DATABASE_STRUCTURE.md` for complete schema

**Edge Functions:**
- Located in `../supabase/functions/login-register/`
- Endpoints: `/v1/login`, `/v1/register`, `/v1/get_user`, `/v1/sync_memberships`, etc.
- Handle WordPress RCP sync and RevenueCat webhooks
- See `../supabase/README.md` for all available endpoints

### State Management Strategy

**Global State (via BlocProviders in app_bloc_providers.dart):**
- `AuthCubit` - Authentication state (user, token, memberships)
- `AppLayoutCubit` - UI state (dark mode, sidebar, menu)

**Feature State (per-feature Cubits):**
- `SignInCubit` - Sign-in form state
- `TopicCubit` - Topics/content state
- Each feature manages its own state independently

**Listening to State Changes:**
- Global listeners in `app_bloc_listeners.dart`
- Example: `AuthCubit` listener handles auth state changes and navigation

### Code Generation Workflow

When adding new models or state classes:

1. Add `@freezed` annotation to state classes
2. Add `@JsonSerializable()` to model classes
3. Add `.g.dart` and `.freezed.dart` part directives
4. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
5. Generated files are NOT committed (in .gitignore)

**Models requiring generation:**
- State classes (with `@freezed`)
- API models (with `@JsonSerializable()`)
- Example: `CmsUser`, `TopicModel`, `AuthState`

## Important Conventions

### File Naming
- Feature pages: `feature_page.dart` (lowercase with underscores)
- Cubits: `cubit.dart` (NOT `feature_cubit.dart`)
- States: `state.dart` (NOT `feature_state.dart`)
- Routes: Each page has a static `route` constant (e.g., `SignInPage.route = '/signin'`)

### State Classes
- Always use `freezed` for immutability
- Define unions for different states (loading, success, error)
- Example pattern:
  ```dart
  @freezed
  class FeatureState with _$FeatureState {
    const factory FeatureState.initial() = _Initial;
    const factory FeatureState.loading() = _Loading;
    const factory FeatureState.success(Data data) = _Success;
    const factory FeatureState.error(String message) = _Error;
  }
  ```

### Repository Pattern
- Repositories are registered as factories in GetIt (NOT singletons)
- Always inject repositories into Cubits via constructor
- Use try-catch in repositories, throw exceptions on error
- Log errors with `logger.error()` from Talker

### Navigation
- Never use `Navigator.push()` directly - use GoRouter context extensions
- Routes defined as constants in `AppRoutes` class
- Use `context.go()` for replace, `context.push()` for stack
- Pages declare their own route: `static const String route = '/path'`

### Theme Usage
- Always use `Theme.of(context).colorScheme.*` for colors
- Never hardcode colors like `Color(0xFF...)` in widgets
- Use predefined text styles: `Theme.of(context).textTheme.*`
- Icons: Use `AppIcons` constants or Material/Cupertino icons

### Environment Configuration
- Three environments: development (local), staging, production
- Switch via `BuildVariant` enum in `main.dart`
- Development uses local Supabase (127.0.0.1:54321)
- Production uses hosted Supabase
- **Never commit API keys or secrets to git**

## Testing Strategy

### Unit Tests
- Test Cubits with mock repositories
- Test repositories with mock Supabase client
- Use `mocktail` for mocking

### Widget Tests
- Test individual widgets in isolation
- Use `BlocProvider.value()` to provide test Cubits
- Mock navigation with test `GoRouter`

### Integration Tests
- Test full features end-to-end
- Use local Supabase for integration tests
- Test authentication flow, content loading, etc.

## Common Gotchas

1. **Android Emulator Supabase Connection:**
   - Use `10.0.2.2` instead of `127.0.0.1`
   - This is handled automatically in `environment.dart`

2. **Code Generation:**
   - Always run build_runner after adding/modifying models
   - Delete conflicting outputs with `--delete-conflicting-outputs`
   - Generated files (.g.dart, .freezed.dart) are gitignored

3. **BLoC Context Issues:**
   - Don't access Cubit immediately after creation
   - Use `context.read<CubitName>()` to access, not `BlocProvider.of<>()`

4. **GoRouter Navigation:**
   - Routes must start with `/`
   - Don't mix Navigator and GoRouter
   - Router is created once in `MyApp.initState()` to prevent rebuilds

5. **Supabase Auth:**
   - `cms_users.user_uuid` must match `auth.users.id`
   - Always fetch user data after authentication
   - Session tokens are stored in Supabase client automatically

6. **Theme Rebuilds:**
   - Theme mode controlled by `AppLayoutCubit.isDarkMode`
   - Router created once to avoid navigation state loss on theme change

## Related Documentation

- **Navigation System:** `lib/app/config/go_route/README.md`
- **Theme System:** `lib/app/config/theme/README.md`
- **Theme Examples:** `lib/app/config/theme/EXAMPLES.md`
- **Supabase Setup:** `../supabase/README.md`
- **Database Schema:** `../supabase/docs/DATABASE_STRUCTURE.md`
- **Membership System:** `../supabase/docs/SISTEMA_MEMBRESIAS.md`

## Local Development URLs

When Supabase is running locally:
- **Supabase API:** http://127.0.0.1:54321
- **Supabase Studio:** http://127.0.0.1:54323
- **PostgreSQL:** postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Inbucket (Email Testing):** http://127.0.0.1:54324
- **Edge Functions:** http://127.0.0.1:54321/functions/v1/login-register