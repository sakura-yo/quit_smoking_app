// 参考画像のルールで adaptive_icon_foreground.png を生成
// ・白のみ / 背景透過
// ・太い時計の円（リング）、内側に 12,3,6,9
// ・円と同じ太さの禁止斜め線
// ・中心にタバコ（横長・右がやや太い）+ 煙（左端から2本の細い曲線）
// Run: dart run bin/create_adaptive_icon_foreground.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const size = 512;
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  const clockRadius = 200;
  const circleThickness = 26; // 円の太さ（参考画像に合わせた）
  const innerRadius = clockRadius - circleThickness;

  final white = img.ColorUint8.rgba(255, 255, 255, 255);
  final transparent = img.ColorUint8.rgba(0, 0, 0, 0);

  final out = img.Image(width: size, height: size, numChannels: 4);
  out.clear(transparent);

  // 1. 時計の円（太い白リング）：塗り円の内側を透明にしてリングにする
  img.fillCircle(out,
      x: cx,
      y: cy,
      radius: clockRadius,
      color: white,
      antialias: true,
      blend: img.BlendMode.alpha);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy < innerRadius * innerRadius) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  // 2. 中心にタバコ（横長・角丸）+ 煙（2本の細い曲線）
  _drawCigaretteAndSmoke(out, cx, cy, white);

  // 3. 禁止マークの斜め線（円と同じ太さ）
  final d = (clockRadius * math.sqrt2).round() + 2;
  img.drawLine(out,
      x1: cx - d,
      y1: cy - d,
      x2: cx + d,
      y2: cy + d,
      color: white,
      antialias: true,
      thickness: circleThickness.toDouble(),
      blend: img.BlendMode.alpha);

  // 4. 数字 12, 3, 6, 9（円の内側縁に配置・参考画像に合わせてやや内側）
  final font = img.arial48;
  const numRadius = innerRadius - 36; // 内側に寄せる
  img.drawString(out, '12',
      font: font,
      x: cx - 40,
      y: cy - numRadius - 24,
      color: white,
      blend: img.BlendMode.alpha);
  img.drawString(out, '3',
      font: font,
      x: cx + numRadius - 20,
      y: cy - 24,
      color: white,
      blend: img.BlendMode.alpha);
  img.drawString(out, '6',
      font: font,
      x: cx - 24,
      y: cy + numRadius - 48,
      color: white,
      blend: img.BlendMode.alpha);
  img.drawString(out, '9',
      font: font,
      x: cx - numRadius - 24,
      y: cy - 24,
      color: white,
      blend: img.BlendMode.alpha);

  final outPath = 'assets/icons/adaptive_icon_foreground.png';
  File(outPath).writeAsBytesSync(img.encodePng(out));
  print('Saved $outPath');
}

void _drawCigaretteAndSmoke(
    img.Image out, int cx, int cy, img.ColorUint8 white) {
  const halfLen = 52;
  const halfH = 10;
  const radius = 6;
  final x1 = cx - halfLen;
  final x2 = cx + halfLen;
  final y1 = cy - halfH;
  final y2 = cy + halfH;
  img.fillRect(out,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: white,
      radius: radius,
      alphaBlend: true);

  // 煙：左端（火のついている側）から2本の細い曲線が上方向に
  final smokeStartX = cx - halfLen;
  final smokeStartY = cy;
  const smokeThickness = 2.0;
  // 1本目：やや上・右へカーブ
  _drawCurve(out, smokeStartX - 2, smokeStartY,
      smokeStartX + 15, smokeStartY - 45,
      smokeStartX + 35, smokeStartY - 70, white, smokeThickness);
  // 2本目：もう少し右から、同様に上へ
  _drawCurve(out, smokeStartX + 4, smokeStartY - 5,
      smokeStartX + 28, smokeStartY - 50,
      smokeStartX + 50, smokeStartY - 75, white, smokeThickness);
}

void _drawCurve(img.Image out, int x0, int y0, int x1, int y1, int x2, int y2,
    img.Color color, num thickness) {
  const steps = 24;
  var px = x0.toDouble();
  var py = y0.toDouble();
  for (var i = 1; i <= steps; i++) {
    final t = i / steps;
    final t1 = 1 - t;
    final x = (t1 * t1 * x0 + 2 * t1 * t * x1 + t * t * x2).round();
    final y = (t1 * t1 * y0 + 2 * t1 * t * y1 + t * t * y2).round();
    img.drawLine(out,
        x1: px.round(),
        y1: py.round(),
        x2: x,
        y2: y,
        color: color,
        antialias: true,
        thickness: thickness,
        blend: img.BlendMode.alpha);
    px = x.toDouble();
    py = y.toDouble();
  }
}
