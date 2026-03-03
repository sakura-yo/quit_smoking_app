// 指定画像を512x512にリサイズして app_icon_512.png として保存
// Run: dart run bin/icon_from_design.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  // ユーザー提供デザイン画像（Cursorのワークスペースに保存されたパス）
  const sourcePath = r'C:\Users\suyo1\.cursor\projects\d-src-quit-smoking-app\assets\c__Users_suyo1_AppData_Roaming_Cursor_User_workspaceStorage_7463e3b023b370b5fe3b2a1b811c82f2_images_image-1f5b225d-1102-4a30-ba7d-fa5edfe69a1a.png';
  const outPath = 'assets/icons/app_icon_512.png';

  final file = File(sourcePath);
  if (!file.existsSync()) {
    print('Source image not found: $sourcePath');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  final src = img.decodeImage(bytes);
  if (src == null) {
    print('Failed to decode image');
    exit(1);
  }

  final resized = img.copyResize(
    src,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.linear,
  );

  // 不透明で保存（アルファがあれば緑で合成）
  const greenR = 0x2E, greenG = 0x7D, greenB = 0x32;
  final out = img.Image(width: 512, height: 512, numChannels: 3);
  for (var y = 0; y < 512; y++) {
    for (var x = 0; x < 512; x++) {
      final p = resized.getPixel(x, y);
      final a = p.a.toInt() / 255.0;
      final r = (p.r.toInt() * a + greenR * (1 - a)).round().clamp(0, 255);
      final g = (p.g.toInt() * a + greenG * (1 - a)).round().clamp(0, 255);
      final b = (p.b.toInt() * a + greenB * (1 - a)).round().clamp(0, 255);
      out.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  File(outPath).writeAsBytesSync(img.encodePng(out));
  print('Saved $outPath (512x512)');
}
