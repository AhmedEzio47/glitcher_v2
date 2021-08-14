import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final String javaScript;
  final Map<String, String> headers;

  WebViewScreen(
      {this.title, @required this.url, this.javaScript, this.headers});

  @override
  _StateWebViewScreen createState() => _StateWebViewScreen();
}

class _StateWebViewScreen extends State<WebViewScreen> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) async {
          _controller = controller;
          await controller.loadUrl(widget.url, headers: widget.headers);
        },
        onPageFinished: (s) async {
          await _controller.evaluateJavascript(widget.javaScript);
        },
      ),
    );
  }
}
