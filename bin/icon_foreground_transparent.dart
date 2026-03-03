// app_icon_512.png から同じデザインで白色のみの前景を生成（アンチエイリアスの薄い緑も透過）
// Run: dart run bin/icon_foreground_transparent.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  // 緑系とみなす色（この範囲内なら透過＝背景扱い）。アンチエイリアスの薄い緑も含める
  const darkGreenR = 0x2E, darkGreenG = 0x7D, darkGreenB = 0x32;
  const yellowGreenR = 0x9C, yellowGreenG = 0xCC, yellowGreenB = 0x65;
  const greenDistSqMax = 28000;   // 濃い緑〜薄い緑まで広めに
  const yellowGreenDistSqMax = 28000;
  const leftEdgeClear = 6;

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
      if (x < leftEdgeClear) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      final p = src.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final dDark = _colorDistSq(r, g, b, darkGreenR, darkGreenG, darkGreenB);
      final dYellow = _colorDistSq(r, g, b, yellowGreenR, yellowGreenG, yellowGreenB);
      final isGreenish = dDark <= greenDistSqMax || dYellow <= yellowGreenDistSqMax;
      if (isGreenish) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
  }

  final outPath = 'assets/icons/adaptive_icon_foreground.png';
  File(outPath).writeAsBytesSync(img.encodePng(out));
  print('Saved $outPath (design as pure white, green/anti-alias=transparent)');
}

int _colorDistSq(int r1, int g1, int b1, int r2, int g2, int b2) {
  final dr = r1 - r2, dg = g1 - g2, db = b1 - b2;
  return dr * dr + dg * dg + db * db;
}
