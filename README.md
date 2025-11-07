# api_anime

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API configuration

This app uses Dio for HTTP requests. The API client lives in `lib/services/api_service.dart`.

- Default baseUrl is `http://192.168.1.8:8000` — change it to match your environment.
- Suggested values for local development:
	- Android Emulator: `http://10.0.2.2:8000`
	- iOS Simulator / Desktop / Web: `http://localhost:8000`
	- Physical device: your computer's LAN IP (e.g. `http://192.168.x.x:8000`)

Timeouts and retry:
- Connect and receive timeouts default to 30 seconds.
- Transient network errors (timeouts, 5xx) will be retried up to 3 times with exponential backoff.
