// 前の画像を512x512にし、白い余白部分を緑で塗りつぶす。
// 端からつながる白を「背景」とみなし緑に。デザインの白（時計等）は残す。
// Run: dart run bin/icon_fill_white_green.dart

import 'dart:io';

import 'package:image/image.dart' as img;

bool isWhite(img.Image im, int x, int y, int thresh) {
  if (x < 0 || x >= im.width || y < 0 || y >= im.height) return false;
  final p = im.getPixel(x, y);
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  return r >= thresh && g >= thresh && b >= thresh;
}

void main() {
  const greenR = 0x2E, greenG = 0x7D, greenB = 0x32;
  const whiteThreshold = 235;

  final path = 'assets/icons/app_icon_1024.png';
  final bytes = File(path).readAsBytesSync();
  final src = img.decodeImage(bytes);
  if (src == null) {
    print('Failed to decode $path');
    exit(1);
  }

  final w = src.width;
  final h = src.height;
  // 端からつながる白ピクセルをマーク（キューで反復、スタックオーバーフロー防止）
  final isBackground = List.generate(w * h, (_) => false);
  final queue = <int>[];
  void push(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    final i = y * w + x;
    if (isBackground[i]) return;
    if (!isWhite(src, x, y, whiteThreshold)) return;
    isBackground[i] = true;
    queue.add(i);
  }

  for (var x = 0; x < w; x++) {
    push(x, 0);
    push(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    push(0, y);
    push(w - 1, y);
  }
  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    push(x - 1, y);
    push(x + 1, y);
    push(x, y - 1);
    push(x, y + 1);
  }

  // 端からつながる白を緑に置換
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (isBackground[y * w + x]) {
        src.setPixelRgba(x, y, greenR, greenG, greenB, 255);
      }
    }
  }
  // 画像の外側20%の白も緑に（白い余白が端と離れている場合）
  final margin = (w > h ? h : w) * 0.2;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final inMargin = x < margin || x >= w - margin || y < margin || y >= h - margin;
      if (inMargin && isWhite(src, x, y, whiteThreshold)) {
        src.setPixelRgba(x, y, greenR, greenG, greenB, 255);
      }
    }
  }

  // 512x512にリサイズ（円切り抜きなし・単純縮小）
  final resized = img.copyResize(
    src,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.linear,
  );

  // アルファなしで保存（3チャンネル、不透明に合成）
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

  final outFile = File('assets/icons/app_icon_512.png');
  outFile.writeAsBytesSync(img.encodePng(out));
  print('Saved ${outFile.path} (512x512, white→green, no alpha)');
}
