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
  late List<int> painValues;
  // int _selectedYesNoValue = 0;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นเมื่อวิดเจ็ตถูกสร้างขึ้น
    _selectedPainValue = widget.initialPainValue;
    painValues = List<int>.generate(10, (index) => index + 1);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // final double availableWidth =
        //     constraints.maxWidth - (horizontalPadding * 2);
        final double fontSize =
            constraints.maxWidth < 680
                ? 14.0
                : 16.0; // ปรับขนาดฟอนต์ตามความกว้าง
        final double arrowSize =
            constraints.maxWidth < 680 ? 20.0 : 25.0; // ปรับขนาดลูกศร

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLineCheckBox(
                  maxWidth: constraints.maxWidth,
                  painValues: painValues,
                  fontSize: fontSize,
                  arrowSize: arrowSize,
                  labelLeft: widget.labelLeft,
                  labelRight: widget.labelRight,
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        );
      },
    );
  }

  double calculateSidePadding(double maxWidth) {
    const double baseWidth = 1188;
    const double stepWidth = 200; // ทุก ๆ 200px ลดลงทีละ 10
    const double startPadding = 85;
    const double minPadding = 20;

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
                  return Expanded(
                    child: InkWell(
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
                                            style: TextStyle(
                                              fontSize: fontSize,
                                            ),
                                          )
                                          : Text(
                                            labelRight,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                            ),
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
                              checkColor:
                                  Colors.blue[700], // สีของเครื่องหมายถูก
                              materialTapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap, // ให้ขนาดเล็กลง
                              visualDensity:
                                  VisualDensity.compact, // ขนาด compact
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
