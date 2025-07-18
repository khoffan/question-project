import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyGridCanvasWidget extends StatefulWidget {
  const BodyGridCanvasWidget({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<BodyGridCanvasWidget> createState() => _BodyGridCanvasWidgetState();
}

class _BodyGridCanvasWidgetState extends State<BodyGridCanvasWidget> {
  final List<Offset> circlePoints = [];
  ui.Image? bodyImage;
  ByteData? imagePixels;

  final double canvasWidth = 300;
  final double canvasHeight = 800;

  @override
  void initState() {
    super.initState();
    loadBodyImage(widget.imagePath);
  }

  Future<void> loadBodyImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List list = Uint8List.view(data.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(list);
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    setState(() {
      bodyImage = fi.image;
      imagePixels = byteData;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (bodyImage == null || imagePixels == null) return;

    final local = details.localPosition;

    // ตรวจสอบขอบเขต
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx >= canvasWidth ||
        local.dy >= canvasHeight) {
      return;
    }

    final scaleX = bodyImage!.width / canvasWidth;
    final scaleY = bodyImage!.height / canvasHeight;

    final x = (local.dx * scaleX).toInt();
    final y = (local.dy * scaleY).toInt();

    final pixelOffset = (y * bodyImage!.width + x) * 4;

    final r = imagePixels!.getUint8(pixelOffset);
    final g = imagePixels!.getUint8(pixelOffset + 1);
    final b = imagePixels!.getUint8(pixelOffset + 2);
    final a = imagePixels!.getUint8(pixelOffset + 3);

    final bool isWhite = (r > 240 && g > 240 && b > 240);
    final bool isTransparent = a > 10;

    final bool isBody = !(isWhite || isTransparent);

    if (isTransparent) {
      setState(() {
        circlePoints.add(local);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        child: CustomPaint(
          size: Size(canvasWidth, canvasHeight),
          painter: BodyGridPainter(
            bodyImage: bodyImage,
            points: circlePoints,
            canvasSize: Size(canvasWidth, canvasHeight),
          ),
        ),
      ),
    );
  }
}

class BodyGridPainter extends CustomPainter {
  final ui.Image? bodyImage;
  final List<Offset> points;
  final Size canvasSize;

  BodyGridPainter({
    required this.bodyImage,
    required this.points,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint =
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke;

    const double cellSize = 100;

    // Draw grid 3 cols
    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), gridPaint);
      }
    }

    // Draw body image scaled to canvas
    if (bodyImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
        image: bodyImage!,
        fit: BoxFit.fill,
      );
    }

    // Draw points
    final Paint circlePaint = Paint()..color = Colors.red;
    for (final point in points) {
      canvas.drawCircle(point, 8, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BodyGridPainter oldDelegate) => true;
}
