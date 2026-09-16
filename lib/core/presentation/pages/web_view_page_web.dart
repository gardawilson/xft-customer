// Web-only implementation. This file is only ever compiled when the build
// target is web (see the conditional import in web_view_page.dart), so it's
// safe to use dart:ui_web / package:web / dart:js_interop here.

import 'dart:ui_web' as ui_web;
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void registerIframeViewFactory(
  String viewId,
  String url,
  void Function() onLoaded,
) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int _) {
    final iframe =
        web.document.createElement('iframe') as web.HTMLIFrameElement
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';

    iframe.addEventListener(
      'load',
      (web.Event _) {
        onLoaded();
      }.toJS,
    );

    return iframe;
  });
}
