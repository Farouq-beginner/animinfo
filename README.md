# api_anime

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.
## Deep Links / Shareable Anime URLs

The app now supports direct navigation to an anime detail page via a path URL (hashless on web):

```
/home/anime/<malId>
```

Example: `https://your-domain.com/home/anime/5114` will open the detail page for the anime with MyAnimeList ID `5114`.

When you open a deep link before the splash has finished, the app will show the splash screen first, then automatically continue to the requested anime detail.

Each anime card and the detail page app bar include a copy-link button (🔗) that places the full shareable URL in the clipboard.

If hosting on a static server, be sure to configure a rewrite of all unknown paths to `index.html` so deep links work after refresh. Example Nginx snippet:

```
location / {
	try_files $uri $uri/ /index.html;
}
```

## Web Path Strategy

Flutter web hash (`/#/`) was removed using `setUrlStrategy(PathUrlStrategy())` in `main.dart` for cleaner URLs.


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
