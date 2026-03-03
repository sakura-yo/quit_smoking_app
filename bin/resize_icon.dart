// Resize app icon: 512x512, content in 312px diameter circle, no alpha.
// Run from project root: dart run bin/resize_icon.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const outputSize = 512;
  const circleDiameter = 312;
  const greenR = 0x2E, greenG = 0x7D, greenB = 0x32;

  final bytes = File('assets/icons/app_icon_1024.png').readAsBytesSync();
  final src = img.decodeImage(bytes);
  if (src == null) {
    print('Failed to decode assets/icons/app_icon_1024.png');
    exit(1);
  }

  // Resize source to fit inside circle (312x312)
  final scaled = img.copyResize(
    src,
    width: circleDiameter,
    height: circleDiameter,
    interpolation: img.Interpolation.linear,
  );

  // Use scaled as-is; getPixel gives r,g,b,a (a=255 if 3-channel)
  final scaledRgba = scaled;

  // Output: 512x512, no transparency (all opaque)
  final out = img.Image(width: outputSize, height: outputSize, numChannels: 4);
  final center = circleDiameter / 2.0;
  final radius = circleDiameter / 2.0;
  const pasteOffset = (outputSize - circleDiameter) ~/ 2; // 100

  for (var oy = 0; oy < outputSize; oy++) {
    for (var ox = 0; ox < outputSize; ox++) {
      final sx = ox - pasteOffset;
      final sy = oy - pasteOffset;
      final inCircle = sx >= 0 &&
          sx < circleDiameter &&
          sy >= 0 &&
          sy < circleDiameter &&
          (sx - center) * (sx - center) + (sy - center) * (sy - center) <=
              radius * radius;

      if (inCircle) {
        final p = scaledRgba.getPixel(sx, sy);
        final a = p.a.toInt() / 255.0;
        final r = (p.r.toInt() * a + greenR * (1 - a)).round().clamp(0, 255);
        final g = (p.g.toInt() * a + greenG * (1 - a)).round().clamp(0, 255);
        final b = (p.b.toInt() * a + greenB * (1 - a)).round().clamp(0, 255);
        out.setPixelRgba(ox, oy, r, g, b, 255);
      } else {
        out.setPixelRgba(ox, oy, greenR, greenG, greenB, 255);
      }
    }
  }

  // Copy to 3-channel image so PNG has no alpha channel (24-bit)
  final outRgb = img.Image(width: outputSize, height: outputSize, numChannels: 3);
  for (var y = 0; y < outputSize; y++) {
    for (var x = 0; x < outputSize; x++) {
      final p = out.getPixel(x, y);
      outRgb.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }
  final outFile = File('assets/icons/app_icon_512.png');
  outFile.writeAsBytesSync(img.encodePng(outRgb));
  print('Saved ${outFile.path} (512x512, content in ${circleDiameter}px circle, no alpha)');
}
