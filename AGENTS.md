# AGENTS.md

Flutter app (package `xft`, "Xing Fu Tang Customer", targets Android/iOS/web). State management is Riverpod 3. Not a git repo.

## Commands
- `flutter pub get` — install deps
- `dart run build_runner build --delete-conflicting-outputs` — regenerate codegen
- `flutter analyze` — lint/static checks (uses stock `flutter_lints`; `analysis_options.yaml` is unmodified)
- `flutter test` — only a placeholder smoke test exists
- `flutter run -d chrome` / `-d windows` for quick debug; app opens under DevicePreview in non-release mode (`lib/main.dart`)

## Codegen
- `freezed` models and the `@riverpod` notifiers generate `*.freezed.dart` / `*.g.dart` files that ARE committed. After editing any `@freezed` class or `@riverpod` notifier, run build_runner and keep generated files consistent.
- Only these files use codegen today: `features/auth/domain/models/{user_model,auth_response}.dart` and `features/auth/presentation/auth_notifier.dart`. Everything else in `lib/` is plain Riverpod code.
- `retrofit` is in `pubspec.yaml` but is NOT used anywhere (no `@RestApi`); services are hand-written Dio classes. Don't assume a service is a Retrofit client.

## API backend switching
- `lib/core/config/app_config.dart` is the one place to switch servers: set `kUseProduction` (`true` = `https://xft.bisagroup.co.id/api`, `false` = local) and edit `kLocalIp` when the local machine's IP changes. Change it there, not in `api_client.dart`.

## Architecture & conventions
- Feature-first layout: `lib/features/<feature>/{presentation,data,domain}`. Shared infrastructure lives in `lib/core/` (`api`, `config`, `router`, `storage`, `theme`, `presentation`).
- Services (`*_service.dart`) are Dio classes exposed via Riverpod `Provider`s; most notifiers are hand-written `AsyncNotifier` + `AsyncNotifierProvider` (e.g. `cart_notifier.dart`, `outlet_notifier.dart`).
- Routing: single go_router config in `lib/core/router/router.dart` (`routerProvider`). Page params travel via `state.extra` (typed, e.g. `OutletModel`) or `state.uri.queryParameters` (e.g. `otp`, `status`) — check which when using a route.
- `lib/core/presentation/pages/web_view_page.dart` is a platform shim using a conditional import: mobile builds compile `web_view_page_mobile.dart`, web builds compile `web_view_page_web.dart` (iframe via `dart.library.html`). Keep both files in sync when touching webview behavior.

## Transport & auth
- Dio client (`lib/core/api/api_client.dart`) injects `Authorization: Bearer <access_token>` on every request via `AuthInterceptor` unless the request carries a `SkipAuth` header. 401s are NOT handled globally — leaf code handles them.
- Tokens live in flutter_secure_storage (`access_token`, `refresh_token`); user profile JSON lives in shared_preferences under `user_data` (`SecureStorageService` / `PrefsStorageService` in `lib/core/storage/storage_service.dart`).
- Backend and UI strings are frequently in Indonesian/Bahasa; keep user-facing messages in Indonesian to match.