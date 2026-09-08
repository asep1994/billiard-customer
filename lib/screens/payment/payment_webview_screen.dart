import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';

/// Shows Duitku's hosted payment page in-app instead of switching to an
/// external browser. Pops itself once Duitku redirects back to our own
/// server (the configured `returnUrl`), or when the customer taps "Selesai"
/// as a manual fallback. Either way, the caller should re-check the
/// booking's actual payment status afterwards rather than trusting this
/// screen's own guess of what happened.
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  final String paymentUrl;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  final _returnOrigin = apiOrigin();
  bool _isLoading = true;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            _popIfReturned(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _popIfReturned(String url) {
    if (_popped || !url.startsWith(_returnOrigin)) return;
    _popped = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Selesai')),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const LinearProgressIndicator(color: AppColors.primary, minHeight: 2),
        ],
      ),
    );
  }
}
