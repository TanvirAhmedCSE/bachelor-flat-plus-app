import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Replace with your actual Cloudinary credentials
  static const String _cloudName = 'XXXXXXX';
  static const String _uploadPreset = 'XXXXXXX'; // unsigned preset

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseJson = json.decode(String.fromCharCodes(responseData));
      if (response.statusCode == 200) {
        return responseJson['secure_url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
