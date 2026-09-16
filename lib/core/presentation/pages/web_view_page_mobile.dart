// Stub used for non-web platforms (Android, iOS, desktop).
// This file intentionally does NOT import `package:web` or `dart:ui_web`,
// so it never gets compiled against those web-only APIs on mobile builds.

void registerIframeViewFactory(
  String viewId,
  String url,
  void Function() onLoaded,
) {
  // No-op on mobile: WebViewPage uses webview_flutter's WebViewController
  // instead, handled directly in web_view_page.dart.
}
