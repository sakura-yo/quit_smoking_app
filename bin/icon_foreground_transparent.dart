// app_icon_512.png の緑部分を透過、白部分のみ残して adaptive_icon_foreground 用に保存
// Run: dart run bin/icon_foreground_transparent.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const greenR = 0x2E, greenG = 0x7D, greenB = 0x32;
  // 緑とみなす二乗距離の閾値（RGB空間、この値以下なら透過）
  const greenDistSqThreshold = 7200; // 約85の距離に相当

  final bytes = File('assets/icons/app_icon_512.png').readAsBytesSync();
  final src = img.decodeImage(bytes);
  if (src == null) {
    print('Failed to decode assets/icons/app_icon_512.png');
    exit(1);
  }

  final w = src.width;
  final h = src.height;
  final out = img.Image(width: w, height: h, numChannels: 4);

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final distSq = _colorDistSq(r, g, b, greenR, greenG, greenB);
      if (distSq <= greenDistSqThreshold) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  final outPath = 'assets/icons/adaptive_icon_foreground.png';
  File(outPath).writeAsBytesSync(img.encodePng(out));
  print('Saved $outPath (green=transparent, white=opaque)');
}

int _colorDistSq(int r1, int g1, int b1, int r2, int g2, int b2) {
  final dr = r1 - r2;
  final dg = g1 - g2;
  final db = b1 - b2;
  return dr * dr + dg * dg + db * db;
}
