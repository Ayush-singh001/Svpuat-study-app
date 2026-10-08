import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/ui_helpers.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  static const MethodChannel _secureChannel = MethodChannel('com.example.svpuat/secure_screen');

  String? _localPdfPath;
  bool _isLoading = true;
  String? _errorMessage;

  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _enableSecureScreen();
    _downloadAndPreparePdf();
  }

  @override
  void dispose() {
    _disableSecureScreen();
    _cleanupTempFile();
    super.dispose();
  }

  Future<void> _enableSecureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _secureChannel.invokeMethod('enableSecure');
      } catch (e) {
        debugPrint('FLAG_SECURE enable error: $e');
      }
    }
  }

  Future<void> _disableSecureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _secureChannel.invokeMethod('disableSecure');
      } catch (e) {
        debugPrint('FLAG_SECURE disable error: $e');
      }
    }
  }

  Future<void> _downloadAndPreparePdf() async {
    try {
      final api = ApiService();
      final proxyUri = Uri.parse(
        '${ApiService.baseUrl}/upload/stream-pdf?url=${Uri.encodeComponent(widget.pdfUrl)}',
      );

      final headers = <String, String>{};
      if (api.authToken != null && api.authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${api.authToken}';
      }

      final response = await http.get(proxyUri, headers: headers);

      if (response.statusCode != 200) {
        // Fallback: direct load if proxy is offline in test mode
        final fallbackRes = await http.get(Uri.parse(widget.pdfUrl));
        if (fallbackRes.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await tempFile.writeAsBytes(fallbackRes.bodyBytes);
          if (!mounted) return;
          setState(() {
            _localPdfPath = tempFile.path;
            _isLoading = false;
          });
          return;
        }
        throw Exception('Failed to load PDF document (${response.statusCode})');
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      setState(() {
        _localPdfPath = tempFile.path;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _cleanupTempFile() async {
    if (_localPdfPath != null) {
      try {
        final file = File(_localPdfPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                'Page ${_currentPage + 1} of $_totalPages • Read-Only Mode',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        actions: const [
          // Strict Read-Only UI: NO Download button, NO Save button, NO Share button
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingStateView(message: 'Streaming secure PDF document...')
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _downloadAndPreparePdf();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    PDFView(
                      filePath: _localPdfPath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                        });
                      },
                      onViewCreated: (PDFViewController controller) {
                        _pdfViewController = controller;
                      },
                      onPageChanged: (int? page, int? total) {
                        setState(() {
                          _currentPage = page ?? 0;
                          _totalPages = total ?? 0;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          _errorMessage = error.toString();
                        });
                      },
                    ),

                    // Floating Navigation Controls
                    if (_totalPages > 1)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                onPressed: _currentPage > 0
                                    ? () => _pdfViewController?.setPage(_currentPage - 1)
                                    : null,
                              ),
                              Text(
                                '${_currentPage + 1} / $_totalPages',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                onPressed: _currentPage < _totalPages - 1
                                    ? () => _pdfViewController?.setPage(_currentPage + 1)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
