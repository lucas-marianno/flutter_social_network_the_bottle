import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveTemporaryNetworkImage(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) return null;

  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}/tempImg.jpg';
  await Dio().download(imageUrl, path);
  return path;
}
