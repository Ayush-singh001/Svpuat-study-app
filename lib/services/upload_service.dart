import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class UploadResult {
  final bool success;
  final bool isConfigured;
  final String? fileUrl;
  final String? publicId;
  final String? fileName;
  final String? fileSize;
  final String message;

  UploadResult({
    required this.success,
    this.isConfigured = true,
    this.fileUrl,
    this.publicId,
    this.fileName,
    this.fileSize,
    required this.message,
  });
}

class UploadService {
  final ApiService _api = ApiService();

  // Pick PDF file from device
  Future<PlatformFile?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  }

  // Upload file to Cloudinary via Express Backend
  Future<UploadResult> uploadFile(PlatformFile file) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);

      if (_api.authToken != null) {
        request.headers['Authorization'] = 'Bearer ${_api.authToken}';
      }

      if (kIsWeb || file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ));
      } else {
        return UploadResult(
          success: false,
          message: 'Unable to read file content from device.',
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UploadResult(
          success: true,
          fileUrl: body['fileUrl'],
          publicId: body['publicId'],
          fileName: body['fileName'],
          fileSize: body['fileSize'],
          message: body['message'] ?? 'Upload successful',
        );
      } else {
        return UploadResult(
          success: false,
          isConfigured: body['isConfigured'] ?? true,
          message: body['message'] ?? 'Upload failed (${response.statusCode})',
        );
      }
    } catch (e) {
      return UploadResult(
        success: false,
        message: 'Network / Connection error: $e',
      );
    }
  }
}
