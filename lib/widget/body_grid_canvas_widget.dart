import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questionnaire/model/answer_model.dart';

class BodyLabel {
  final String text;
  final Offset position;

  BodyLabel({required this.text, required this.position});
}

class BodyGridCanvasWidget extends StatefulWidget {
  const BodyGridCanvasWidget({
    super.key,
    required this.imagePath,
    required this.questionId,
    required this.label,
    required this.onTap,
  });
  final String imagePath;
  final String questionId;
  final String label;
  final Function(Map<String, List<TapPointEntity>>) onTap;

  @override
  State<BodyGridCanvasWidget> createState() => _BodyGridCanvasWidgetState();
}

class _BodyGridCanvasWidgetState extends State<BodyGridCanvasWidget> {
  final Map<String, List<TapPointEntity>> circlePointMap = {};
  ui.Image? bodyImage;
  ByteData? imagePixels;

  final double canvasWidth = 300;
  final double canvasHeight = 580;
  // final List<BodyLabel> bodyLabels = [
  //   BodyLabel(text: 'หัว', position: Offset(130, 20)),
  //   BodyLabel(text: 'คอ', position: Offset(135, 70)),
  //   BodyLabel(text: 'ไหล่', position: Offset(50, 80)),
  //   BodyLabel(text: 'แขน', position: Offset(30, 150)),
  //   BodyLabel(text: 'ศอก', position: Offset(25, 200)),
  //   BodyLabel(text: 'หน้าอก', position: Offset(110, 120)),
  //   BodyLabel(text: 'น่อง', position: Offset(130, 300)),
  //   BodyLabel(text: 'ขา', position: Offset(130, 350)),
  //   BodyLabel(text: 'เท้า', position: Offset(130, 420)),
  // ];

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

  void _handleTapDown(TapDownDetails details, String label) {
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

    // final r = imagePixels!.getUint8(pixelOffset);
    // final g = imagePixels!.getUint8(pixelOffset + 1);
    // final b = imagePixels!.getUint8(pixelOffset + 2);
    final a = imagePixels!.getUint8(pixelOffset + 3);

    final bool isTransparent = a > 10;

    if (isTransparent) {
      setState(() {
        circlePointMap
            .putIfAbsent(label, () => [])
            .add(TapPointEntity.fromOffset(local));
      });
      widget.onTap(circlePointMap);
    }
  }

  void _clearPoints() {
    setState(() {
      circlePointMap.remove(widget.label);
    });
  }

  // void _savePoints() {
  //   print("tap map: ${circlePointMap}");
  //   context.read<AnswerCubit>().saveAnswer(
  //     questionId: widget.questionId,
  //     value: "",
  //     tapPoints: circlePointMap,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (details) => _handleTapDown(details, widget.label),
            child: CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: BodyGridPainter(
                bodyImage: bodyImage,
                points: circlePointMap[widget.label] ?? [],
                canvasSize: Size(canvasWidth, canvasHeight),
                // labels: bodyLabels,
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed:
                    circlePointMap[widget.label]?.isNotEmpty ?? false
                        ? _clearPoints
                        : null,
                child: Text('questionire.button.clear'.tr()),
              ),
              const SizedBox(width: 20),
              // ElevatedButton(
              //   onPressed:
              //       circlePointMap[widget.label]?.isNotEmpty ?? false
              //           ? _savePoints
              //           : null,
              //   child: Text('questionire.button.save'.tr()),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class BodyGridPainter extends CustomPainter {
  final ui.Image? bodyImage;
  final List<TapPointEntity> points;
  final Size canvasSize;
  final List<BodyLabel>? labels;

  BodyGridPainter({
    required this.bodyImage,
    required this.points,
    required this.canvasSize,
    this.labels,
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

    if (labels != null && labels!.isNotEmpty) {
      for (final label in labels!) {
        final textSpan = TextSpan(
          text: label.text,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white.withValues(alpha: 0.5),
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, label.position);
      }
    }

    // Draw points
    final Paint circlePaint = Paint()..color = Colors.red;
    for (final point in points) {
      canvas.drawCircle(point.toOffset(), 8, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BodyGridPainter oldDelegate) => true;
}
