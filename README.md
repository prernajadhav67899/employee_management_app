# Employee Management App

A Flutter application for managing employee records, built with Firebase
Authentication and a REST backend. Demonstrates Clean Architecture, the
Repository Pattern, Provider state management, and unit/widget testing.

## Features

**Authentication**
- Email/password login and registration
- Google Sign-In (google_sign_in v7)
- Forgot password via Firebase reset email
- Persistent session — a signed-in user skips the login screen on relaunch
- Logout with confirmation

**Employee management**
- List all employees with name, email, mobile, country, state, district
- Search by ID (hits `GET /employee/:id` directly)
- Filter by name, email, mobile or country
- Add, edit, view and delete employees
- Edit form pre-populated from the selected record
- Delete confirmation dialog
- Pull-to-refresh
- Local state updates after every CRUD operation

**UI/UX**
- Light and dark themes, persisted across restarts
- Responsive layouts constrained for tablet widths
- Loading, error and empty states throughout
- Success feedback via SnackBars
- Reusable widget library

## Architecture