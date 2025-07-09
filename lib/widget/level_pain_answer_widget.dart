import 'package:flutter/material.dart';

// นี่คือวิดเจ็ตแสดงผลมาตรวัดความเจ็บปวดที่สามารถคลิกได้และตอบสนองต่อขนาดหน้าจอ
class LavelPainWidget extends StatefulWidget {
  // ตัวแปรสำหรับเก็บค่าความเจ็บปวดที่เลือกไว้
  final ValueChanged<int?>? onPainSelected;
  // ค่าเริ่มต้นของความเจ็บปวด (ถ้ามี)
  final int? initialPainValue;
  final String labelLeft;
  final String labelRight;

  const LavelPainWidget({
    super.key,
    this.onPainSelected,
    this.initialPainValue,
    required this.labelLeft,
    required this.labelRight,
  });

  @override
  State<LavelPainWidget> createState() => _LavelPainWidgetState();
}

class _LavelPainWidgetState extends State<LavelPainWidget> {
  // สถานะปัจจุบันของค่าความเจ็บปวดที่ถูกเลือก
  int? _selectedPainValue;
  // int _selectedYesNoValue = 0;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นเมื่อวิดเจ็ตถูกสร้างขึ้น
    _selectedPainValue = widget.initialPainValue;
  }

  // ฟังก์ชันสำหรับจัดการเมื่อมีการเลือกค่าความเจ็บปวด
  void _handlePainSelection(int value) {
    setState(() {
      // สลับการเลือก: ถ้าคลิกค่าเดิมจะยกเลิกการเลือก ถ้าคลิกค่าใหม่จะเลือกค่านั้น
      _selectedPainValue = (_selectedPainValue == value) ? null : value;
    });
    // เรียก callback function ที่ส่งมาจาก parent widget
    widget.onPainSelected?.call(_selectedPainValue);
  }

  @override
  Widget build(BuildContext context) {
    // สร้างรายการของตัวเลข 0 ถึง 10
    final List<int> painValues = List<int>.generate(11, (index) => index);

    return LayoutBuilder(
      builder: (context, constraints) {
        // กำหนดขนาดของช่องว่างและข้อความตามความกว้างของหน้าจอ
        final double horizontalPadding =
            constraints.maxWidth * 0.05; // 5% ของความกว้าง
        // final double availableWidth =
        //     constraints.maxWidth - (horizontalPadding * 2);
        final double fontSize =
            constraints.maxWidth < 600
                ? 14.0
                : 16.0; // ปรับขนาดฟอนต์ตามความกว้าง
        final double arrowSize =
            constraints.maxWidth < 600 ? 20.0 : 25.0; // ปรับขนาดลูกศร

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              _buildLineCheckBox(
                maxWidth: constraints.maxWidth,
                painValues: painValues,
                fontSize: fontSize,
                arrowSize: arrowSize,
                labelLeft: widget.labelLeft,
                labelRight: widget.labelRight,
              ),

              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  double calculateSidePadding(double maxWidth) {
    const double baseWidth = 1188;
    const double stepWidth = 200; // ทุก ๆ 200px ลดลงทีละ 10
    const double startPadding = 75;
    const double minPadding = 15;

    // คำนวณจำนวนช่วงที่ลดลง
    final double diff = baseWidth - maxWidth;
    final int steps = (diff / stepWidth).floor();

    final double calculated = startPadding - (steps * 20);
    return calculated.clamp(minPadding, startPadding);
  }

  _buildLineCheckBox({
    required double maxWidth,
    required List<int> painValues,
    required double fontSize,
    required double arrowSize,
    required String labelLeft,
    required String labelRight,
  }) {
    double sidePadding = calculateSidePadding(maxWidth);

    return SizedBox(
      width: maxWidth,
      child: Stack(
        children: [
          Positioned(
            left: sidePadding,
            right: sidePadding,
            top: 25,
            child: Container(height: 2, color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                painValues.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final int value = entry.value;
                  return InkWell(
                    onTap: () => _handlePainSelection(value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            if (idx == 0 || idx == painValues.length - 1) ...[
                              Positioned(
                                top: -arrowSize * 0.8, // ปรับให้ลอยขึ้น
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: arrowSize,
                                ),
                              ),
                              Positioned(
                                top: -arrowSize * 1.6,
                                child:
                                    idx == 0
                                        ? Text(
                                          labelLeft,
                                          style: TextStyle(fontSize: fontSize),
                                        )
                                        : Text(
                                          labelRight,
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                              ),
                            ],
                            Text(
                              value.toString(),
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ],
                        ),

                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.black,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: Offset(0, -10),
                          child: Checkbox(
                            value: _selectedPainValue == value,
                            onChanged: (_) => _handlePainSelection(value),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: WidgetStateBorderSide.resolveWith(
                              (states) => const BorderSide(
                                width: 1.5,
                                color: Colors.black,
                              ),
                            ),
                            activeColor:
                                Colors.blue[100], // สีพื้นหลังเมื่อถูกเลือก
                            checkColor: Colors.blue[700], // สีของเครื่องหมายถูก
                            materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap, // ให้ขนาดเล็กลง
                            visualDensity:
                                VisualDensity.compact, // ขนาด compact
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// Custom Painter สำหรับวาดเส้นแนวนอนและแนวตั้ง
class PainScalePainter extends CustomPainter {
  final double itemSpacing; // ระยะห่างระหว่างจุดศูนย์กลางของแต่ละรายการ
  final int totalItems; // จำนวนรายการทั้งหมด (0-10 คือ 11 รายการ)
  final double verticalLineLength; // ความยาวของเส้นแนวตั้งแต่ละส่วน
  final double horizontalLineThickness; // ความหนาของเส้นแนวนอนหลัก

  PainScalePainter({
    required this.itemSpacing,
    required this.totalItems,
    required this.verticalLineLength,
    required this.horizontalLineThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth =
              horizontalLineThickness // กำหนดความหนาเริ่มต้นสำหรับเส้นแนวนอน
          ..strokeCap = StrokeCap.butt; // กำหนดรูปแบบปลายเส้น

    // ตำแหน่ง Y ของเส้นแนวนอนหลักภายใน CustomPaint (เริ่มจาก 0 ที่ด้านบน)
    final double horizontalLineY = verticalLineLength;

    // วาดเส้นแนวนอนหลักที่กึ่งกลางของพื้นที่ CustomPaint
    canvas.drawLine(
      Offset(0, horizontalLineY),
      Offset(size.width, horizontalLineY),
      paint,
    );

    // วาดเส้นแนวตั้งสำหรับแต่ละจุด
    for (int i = 0; i < totalItems; i++) {
      // คำนวณตำแหน่ง X สำหรับเส้นแนวตั้งแต่ละเส้น (จุดศูนย์กลางของรายการ)
      final double x = i * itemSpacing;

      // เส้นแนวตั้งจากด้านบน (จากตัวเลขลงมาถึงเส้นแนวนอนหลัก)
      canvas.drawLine(
        Offset(x, 0), // เริ่มต้นที่ด้านบนของ CustomPaint (y=0)
        Offset(x, horizontalLineY), // สิ้นสุดที่เส้นแนวนอนหลัก
        paint..strokeWidth = 1.5, // กำหนดความหนาของเส้นแนวตั้งให้บางลง
      );

      // เส้นแนวตั้งจากด้านล่าง (จากเส้นแนวนอนหลักลงไปถึงกล่อง)
      canvas.drawLine(
        Offset(x, horizontalLineY), // เริ่มต้นที่เส้นแนวนอนหลัก
        Offset(
          x,
          horizontalLineY + verticalLineLength,
        ), // สิ้นสุดที่ด้านล่างของ CustomPaint
        paint..strokeWidth = 1.5, // กำหนดความหนาของเส้นแนวตั้งให้บางลง
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // ให้วาดใหม่เมื่อค่าพารามิเตอร์เปลี่ยนแปลง เพื่อให้ UI อัปเดตตาม
    return true;
  }
}
