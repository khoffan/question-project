import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class WeightScaleSliderWidget extends StatefulWidget {
  final double from;
  final double max;
  final double initialValue;
  final Function(double) onChanged;

  const WeightScaleSliderWidget({
    super.key,
    required this.from,
    required this.max,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<WeightScaleSliderWidget> createState() =>
      _WeightScaleSliderWidgetState();
}

class _WeightScaleSliderWidgetState extends State<WeightScaleSliderWidget> {
  PageController? numbersController;
  final itemsExtension = 100;
  late double value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  void _updateValue() {
    value = ((((numbersController?.page ?? 0) - itemsExtension) * 10)
                .roundToDouble() /
            10)
        .clamp(widget.from, widget.max);
    widget.onChanged(value);
  }

  @override
  void dispose() {
    numbersController?.removeListener(_updateValue);
    numbersController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewPortFraction = 1 / (constraints.maxWidth / 10);
        numbersController = PageController(
          initialPage: itemsExtension + widget.initialValue.toInt(),
          viewportFraction: viewPortFraction * 10,
        );
        numbersController?.addListener(_updateValue);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Score: $value",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 10,
              width: 10,
              child: CustomPaint(
                painter: TrianglePainter(greenColor: Colors.green),
              ),
            ),
            _Numbers(
              controller: numbersController,
              itemsExtension: itemsExtension,
              start: widget.from.toInt(),
              end: widget.max.toInt(),
            ),
          ],
        );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  TrianglePainter({required this.greenColor});

  final Color greenColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = greenColor;
    Paint paint2 =
        Paint()
          ..color = greenColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
    canvas.drawPath(line(size.width, size.height), paint2);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..lineTo(x, 0)
      ..lineTo(x / 2, y)
      ..lineTo(0, 0);
  }

  Path line(double x, double y) {
    return Path()
      ..moveTo(x / 2, 0)
      ..lineTo(x / 2, y * 2);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return true;
  }
}

class _Numbers extends StatelessWidget {
  final PageController? controller;
  final int itemsExtension;
  final int start;
  final int end;

  const _Numbers({
    required this.controller,
    required this.itemsExtension,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (controller == null) return;
        controller!.jumpTo(controller!.offset - details.delta.dx);
      },
      onTapDown: (details) {
        if (controller == null) return;

        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final tapX = localPos.dx;

        final viewportWidth = box.size.width;
        final pageWidth = viewportWidth * controller!.viewportFraction;
        final center = viewportWidth / 2;

        final offsetFromCenter = tapX - center;
        final tappedPageDelta = offsetFromCenter / pageWidth;

        final newPage = (controller!.page ?? 0) + tappedPageDelta;
        final clampedPage = newPage.clamp(
          itemsExtension + start.toDouble(),
          itemsExtension + end.toDouble(),
        );

        controller!.animateToPage(
          clampedPage.round(),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: SizedBox(
        height: 42,
        child: PageView.builder(
          pageSnapping: false,
          controller: controller,
          physics: _CustomPageScrollPhysics(
            start: itemsExtension + start.toDouble(),
            end: itemsExtension + end.toDouble(),
          ),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, rawIndex) {
            final index = rawIndex - itemsExtension;
            return _Item(index: index >= start && index <= end ? index : null);
          },
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final int? index;

  const _Item({required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          const _Dividers(),
          if (index != null)
            Text(
              '$index',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _Dividers extends StatelessWidget {
  const _Dividers();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(10, (index) {
          final thickness = index == 5 ? 1.5 : 0.5;
          return Expanded(
            child: Row(
              children: [
                Transform.translate(
                  offset: Offset(-thickness / 2, 0),
                  child: VerticalDivider(
                    thickness: thickness,
                    width: 1,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CustomPageScrollPhysics extends ScrollPhysics {
  final double start;
  final double end;

  const _CustomPageScrollPhysics({
    required this.start,
    required this.end,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  _CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(
      parent: buildParent(ancestor),
      start: start,
      end: end,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final oldPosition = position.pixels;
    final frictionSimulation = FrictionSimulation(
      0.4,
      position.pixels,
      velocity * 0.2,
    );

    double newPosition = (frictionSimulation.finalX / 10).round() * 10;

    final endPosition = end * 10 * 10;
    final startPosition = start * 10 * 10;
    if (newPosition > endPosition) {
      newPosition = endPosition;
    } else if (newPosition < startPosition) {
      newPosition = startPosition;
    }
    if (oldPosition == newPosition) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      newPosition.toDouble(),
      velocity,
      tolerance: toleranceFor(position),
    );
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 20, stiffness: 100, damping: 0.8);
}
