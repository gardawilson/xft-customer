import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xft/core/presentation/widgets/back_button_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Conditional import: web_view_page_web.dart (which uses dart:ui_web /
// package:web) is only ever compiled when the build target is web.
// On Android/iOS/desktop, web_view_page_mobile.dart (a harmless no-op stub)
// is compiled instead. This avoids "JSObject isn't a type" build errors
// on non-web platforms.
import 'web_view_page_mobile.dart'
    if (dart.library.html) 'web_view_page_web.dart' as platform;

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webview-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      platform.registerIframeViewFactory(_viewId, widget.url, () {
        if (mounted) setState(() => _isLoading = false);
      });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget body;
    if (kIsWeb) {
      body = HtmlElementView(viewType: _viewId);
    } else if (_controller != null) {
      body = WebViewWidget(controller: _controller!);
    } else {
      body = const Center(child: Text('WebView not supported on this platform'));
    }

    return Scaffold(
      appBar: BackButtonAppBar(
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  backgroundColor: colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
      body: body,
    );
  }
}
