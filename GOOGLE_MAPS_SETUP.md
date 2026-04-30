# Google Maps API Key Security Setup

This project uses a secure method to manage Google Maps API keys that prevents them from being accidentally committed to git.

## Setup Instructions

### 1. Create `local.properties` file

1. Copy `local.properties.example` to `local.properties`:
   ```bash
   cp local.properties.example local.properties
   ```

2. Open `local.properties` and add your actual Google Maps API keys:
   ```properties
   GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_ANDROID_GOOGLE_MAPS_API_KEY_HERE
   GOOGLE_MAPS_IOS_API_KEY=YOUR_ACTUAL_IOS_GOOGLE_MAPS_API_KEY_HERE
   ```

### 2. Get Your Google Maps API Key

If you don't have a Google Maps API key yet:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable the "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API keys for both platforms
5. Add the keys to `local.properties`

### 3. Important Notes

- **`local.properties` is git-ignored** - It will never be committed to the repository
- **`local.properties.example`** is provided as a template for new developers
- The API key is automatically injected at build time from `local.properties`
- In Android, the key is injected via manifest placeholders in `build.gradle.kts`

## For Developers

When you first clone the repository:

1. Copy `local.properties.example` to `local.properties`
2. Add your API keys to `local.properties`
3. Run `flutter pub get` and `flutter run` as usual

The app will automatically use the API key from `local.properties` during builds.

## Security Best Practices

- ✅ **DO**: Keep API keys in `local.properties`
- ✅ **DO**: Share `local.properties.example` with the team
- ✅ **DO**: Restrict API key usage in Google Cloud Console (domain, app signatures, etc.)
- ❌ **DON'T**: Commit `local.properties` to git
- ❌ **DON'T**: Share actual API keys in chat or unencrypted channels
- ❌ **DON'T**: Use the same API key for development and production

## Troubleshooting

If Google Maps isn't working:

1. Verify `local.properties` exists and has the correct API key
2. Clean and rebuild: `flutter clean && flutter pub get && flutter run`
3. Check that the API key has Maps SDK enabled in Google Cloud Console
4. For Android, ensure the API key restriction matches your app's package name and debug key hash
