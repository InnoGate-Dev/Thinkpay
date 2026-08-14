import 'dart:io';
import 'package:dio/dio.dart';

// ── Cloudinary configuration ────────────────────────────────────────────────
// TODO: Replace these with your actual Cloudinary credentials.
// You can find them in your Cloudinary dashboard → Settings → Upload presets.
const String _cloudName   = 'YOUR_CLOUD_NAME';       // e.g. 'dayone-media'
const String _uploadPreset = 'YOUR_UNSIGNED_PRESET'; // e.g. 'dayone_unsigned'

/// Uploads a local [File] to Cloudinary and returns the secure access URL.
///
/// This function uses an **unsigned upload preset** so no API secret is
/// exposed on the client.  Create the preset in your Cloudinary dashboard:
///   Dashboard → Settings → Upload → Upload Presets → Add upload preset
///   (set signing mode to "Unsigned").
///
/// Throws a [MediaUploadException] if the upload fails for any reason.
Future<String> uploadMedia(File file) async {
  // CloudinaryObject is available for SDK-based transforms if needed in future.
  // The upload itself uses the Cloudinary REST API directly via Dio.
  try {
    final dio = Dio();

    // Build a multipart form exactly as Cloudinary's REST API expects
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'upload_preset': _uploadPreset,
    });

    final response = await dio.post(
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl != null && secureUrl.isNotEmpty) {
        return secureUrl;
      }
    }

    throw MediaUploadException(
      'Cloudinary returned an unexpected response: ${response.data}',
    );
  } on DioException catch (e) {
    throw MediaUploadException(
      'Network error during upload: ${e.message}',
    );
  } catch (e) {
    if (e is MediaUploadException) rethrow;
    throw MediaUploadException('Unexpected upload error: $e');
  }
}

/// Uploads multiple files concurrently and returns their secure URLs in order.
Future<List<String>> uploadMediaFiles(List<File> files) async {
  final futures = files.map(uploadMedia);
  return Future.wait(futures);
}

/// Thrown when a media upload to Cloudinary fails.
class MediaUploadException implements Exception {
  final String message;
  const MediaUploadException(this.message);

  @override
  String toString() => 'MediaUploadException: $message';
}
