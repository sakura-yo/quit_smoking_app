// cigarette_button.png の黒・暗い背景を透過する
// Run: dart run bin/cigarette_transparent_bg.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  // 明度がこの値以下なら「背景」として透過（黒〜暗いグレーを広めに）
  const luminanceThreshold = 150;
  // または RGB のいずれかがこの値以下で全体が暗い場合も透過
  const maxChannelThreshold = 140;

  final bytes = File('assets/icons/cigarette_button.png').readAsBytesSync();
  final src = img.decodeImage(bytes);
  if (src == null) {
    print('Failed to decode assets/icons/cigarette_button.png');
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
      final a = src.numChannels >= 4 ? p.a.toInt() : 255;
      final luminance = (r + g + b) ~/ 3;
      final maxCh = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final isDark = luminance <= luminanceThreshold ||
          (maxCh <= maxChannelThreshold && luminance <= 160);
      final isSemiTransparentDark = a < 200 && luminance <= 180;
      if (isDark || isSemiTransparentDark) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, r, g, b, a);
      }
    }
  }

  File('assets/icons/cigarette_button.png').writeAsBytesSync(img.encodePng(out));
  print('Saved assets/icons/cigarette_button.png (dark background = transparent)');
}
