# Profile Setup Feature

## Overview
This feature allows users to complete their profile setup after email verification during the signup process.

## Flow
1. User signs up with email, name, phone, and password
2. User verifies email with OTP
3. Instead of going directly to home screen, user is redirected to profile setup screen
4. User fills out profile information:
   - Username (required)
   - Profile picture
   - Emoji
   - About/Bio
   - Location
   - Date of birth
   - Gender
   - Audio introduction
   - Interests (multiple selection)
5. User can either complete setup or skip for now
6. After completion, user is redirected to home screen

## Backend Endpoints

### Social Service (`http://localhost:8001/api/social-service/`)

#### Setup Profile
- **POST** `/setup-profile/`
- **Body:**
```json
{
  "userId": "123",
  "userName": "john_doe",
  "emoji": "😊",
  "about": "I love technology and music",
  "location": "New York",
  "dob": "1990-01-01",
  "gender": "Male",
  "profileImageUrl": "https://example.com/image.jpg",
  "audioUrl": "https://example.com/audio.mp3",
  "interests": ["Technology", "Music", "Sports"]
}
```

#### Get Interests
- **GET** `/get-interests/`
- **Response:**
```json
{
  "status": "success",
  "interests": [
    {"id": 1, "interestName": "Technology"},
    {"id": 2, "interestName": "Music"}
  ]
}
```

#### Check Profile Exists
- **GET** `/check-profile/?userId=123`
- **Response:**
```json
{
  "status": "success",
  "profileExists": true
}
```

#### Get User Profile
- **GET** `/user-profile/?userId=123`
- **Response:**
```json
{
  "status": "success",
  "profile": {
    "userName": "john_doe",
    "emoji": "😊",
    "about": "I love technology and music",
    "location": "New York",
    "dob": "1990-01-01",
    "gender": "Male",
    "profileImageUrl": "https://example.com/image.jpg",
    "audioUrl": "https://example.com/audio.mp3",
    "interests": ["Technology", "Music", "Sports"]
  }
}
```

## Frontend

### New Screen
- `ProfileSetupScreen` - Located at `lib/features/profile/presentation/profile_setup_screen.dart`
- Route: `/profile-setup`

### Models
- `ProfileSetupModel` - Data model for profile setup
- `Interest` - Model for interests
- `ProfileSetupState` - State management for profile setup

### Providers
- `ProfileSetupProvider` - Riverpod provider for managing profile setup state

## Setup Instructions

### Backend
1. Make sure the social service is running on port 8001
2. Run database migrations if needed
3. Optionally populate interests:
   ```bash
   python manage.py populate_interests
   ```

### Frontend
1. The profile setup screen is automatically accessible after OTP verification
2. Users can also navigate to it manually via `/profile-setup`

## Database Tables

### Profile Table (`app_profile`)
- `id` (Primary Key)
- `userId` (Foreign Key to UserAccount)
- `userName` (required)
- `emoji`
- `about`
- `points` (default: 0)
- `isPrivate` (default: False)
- `profileImageUrl`
- `location`
- `dob`
- `gender`
- `audioUrl`

### Interest Table (`app_interest`)
- `id` (Primary Key)
- `interestName` (required)

### UserInterest Table (`app_userinterest`)
- `id` (Primary Key)
- `userId` (Foreign Key to UserAccount)
- `interestId` (Foreign Key to Interest)

## Key Features
- Form validation
- File picker for profile picture and audio
- Date picker for date of birth
- Multi-select interests with chip UI
- Skip option for users who want to complete later
- Responsive UI with dark theme
- Error handling and loading states
- Integration with existing authentication flow

## Testing
1. Sign up with a new account
2. Verify OTP
3. You should be redirected to profile setup screen
4. Fill out the form and submit
5. You should be redirected to home screen
6. Profile data should be saved and accessible
