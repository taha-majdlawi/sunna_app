import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({Key? key}) : super(key: key);

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _totalTasbih = 0;
  int _currentAzkarIndex = 0;
  final int _target = 33;

  // قائمة الأذكار
  final List<String> _azkarList = [
    "سبحان الله وبحمده",
    "سبحان الله العظيم",
    "الحمد لله",
    "الله أكبر",
  ];

  // متغيرات الأنيميشن للموجة
  late AnimationController _rippleController;
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
    if (_counter >= _target) {
      _nextZikr();
      return;
    }

    setState(() {
      _counter++;
      _totalTasbih++;
      // تحديد مكان اللمس بالنسبة لمركز الدائرة
      _tapPosition = details.localPosition;

      // تشغيل أنيميشن الموجة من البداية عند كل ضغطة
      _rippleController.forward(from: 0.0);

      HapticFeedback.lightImpact();
      if (_counter == _target) HapticFeedback.vibrate();
    });
  }

  void _nextZikr() {
    setState(() {
      _counter = 0;
      _currentAzkarIndex = (_currentAzkarIndex + 1) % _azkarList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    double fillPercent = _counter / _target;

    return Scaffold(
    
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "إجمالي التسبيح: $_totalTasbih",
              style: TextStyle(color: colors.secondary),
            ),
            const SizedBox(height: 10),
            Text(
              _azkarList[_currentAzkarIndex],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // منطقة المسبحة التفاعلية
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _handleTap(details, constraints),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. الدائرة الأساسية (الخلفية)
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceVariant.withOpacity(0.2),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),

                      // 2. طبقة الماء التصاعدية
                      ClipOval(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          alignment: Alignment.bottomCenter,
                          width: 280,
                          height: 280,
                          child: Container(
                            height: 280 * fillPercent,
                            color: colors.primary.withOpacity(0.4),
                          ),
                        ),
                      ),

                      // 3. رسم الموجة المائية (Custom Paint)
                      ClipOval(
                        child: AnimatedBuilder(
                          animation: _rippleController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(280, 280),
                              painter: RipplePainter(
                                center: _tapPosition,
                                radiusIndex: _rippleController.value,
                                color: colors.primary.withOpacity(0.5),
                              ),
                            );
                          },
                        ),
                      ),

                      // 4. عداد الأرقام
                      IgnorePointer(
                        // لكي لا يحجب النص اللمس عن الدائرة
                        child: Text(
                          "$_counter",
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: fillPercent > 0.6
                                ? Colors.white
                                : colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            if (_counter == _target)
              ElevatedButton(
                onPressed: _nextZikr,
                child: const Text("انتقل للذكر التالي"),
              ),
          ],
        ),
      ),
    );
  }
}

// الرسام الخاص بالموجة المائية
class RipplePainter extends CustomPainter {
  final Offset center;
  final double radiusIndex;
  final Color color;

  RipplePainter({
    required this.center,
    required this.radiusIndex,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم دائرتين متداخلتين كموجة تنتشر
    final paint = Paint()
      ..color = color
          .withOpacity(1.0 - radiusIndex) // تتلاشى كلما ابتعدت
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // الدائرة الأولى (الموجة الأساسية)
    canvas.drawCircle(center, radiusIndex * 150, paint);

    // الدائرة الثانية (موجة ثانوية أبطأ قليلاً)
    if (radiusIndex > 0.2) {
      final paint2 = Paint()
        ..color = color.withOpacity(0.7 - radiusIndex.clamp(0.0, 0.7))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, (radiusIndex - 0.2) * 120, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
