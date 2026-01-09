# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LCT is an iOS calorie/meal tracking app built with SwiftUI. Users can log meals, view daily calorie progress, and manage their nutrition intake.

## Build Commands

```bash
# Build the project
xcodebuild -project lct.xcodeproj -scheme lct -configuration Debug build

# Run tests
xcodebuild -project lct.xcodeproj -scheme lct test -destination 'platform=iOS Simulator,name=iPhone 15'

# Open in Xcode
open lct.xcodeproj
```

## Architecture

### State Management
- `MealsStore` (ObservableObject) - Central store for meal data, injected via `.environmentObject()` at `MainTabView`
- Views access shared state through `@EnvironmentObject private var mealsStore: MealsStore`

### UI Structure
```
lctApp (entry point)
└── MainTabView (TabView with 3 tabs)
    ├── DashboardView (tab 0) - Calorie progress + meals list
    │   ├── CalorieProgressView - Circular progress indicator
    │   └── MealsListView - NavigationStack with meal list
    │       └── MealRowView - Individual meal display
    ├── AddView (tab 1) - Add new meals
    └── SettingsView (tab 2) - User settings
```

### Navigation
- `MealsListView` uses `NavigationStack` with `NavigationPath` for type-safe navigation
- Navigation destinations are registered for both `DashboardMeal` and `String` routes

### Models
- `DashboardMeal` - Core data model (id, templateId, templateName, calories, mealTime, photoURL)
- Models include `.mockData` static properties for SwiftUI previews
