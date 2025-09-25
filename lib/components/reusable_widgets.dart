import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ajustes_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/text_styles.dart';
import '../core/app_colors.dart';
import 'dart:math' as math;

class CarouselAssets {
  static const List<String> images = [
    'assets/images/carousel/t1.jpg',
    'assets/images/carousel/t2.jpg',
    'assets/images/carousel/t3.jpg',
    'assets/images/carousel/t4.jpg',
    'assets/images/carousel/t5.jpg',
    'assets/images/carousel/t6.jpg',
  ];
}

class TitleSection extends StatelessWidget {
  final String texto;

  const TitleSection({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 44),
      child: SizedBox(
        width: 315,
        height: 65,
        child: Text(texto, style: TextStyles.tituloMotivacional),
      ),
    );
  }
}

//Es la parte de bienvenida
class Bienvenida extends StatelessWidget {
  const Bienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60, left: 44),
      child: SizedBox(
        width: 175,
        height: 42,
        child: Text(
          "Bienvenido/a",
          style: TextStyles.tituloBienvenida,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

//Texto de datos para la parte de inicio
class TextoDatos extends StatelessWidget {
  final String texto;

  const TextoDatos({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 22,
      child: Text(texto, style: TextStyles.textDatos),
    );
  }
}

//Contenedor con diseño
class ContainerC1 extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final Alignment alignment; // 👈 lo guardamos

  static const BoxDecoration _decoration = BoxDecoration(
    color: Color.fromRGBO(224, 231, 255, 0.85),
    borderRadius: BorderRadius.all(Radius.circular(15)),
    border: Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(165, 180, 252, 0.41), width: 1),
    ),
  );

  const ContainerC1({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: _decoration,
      child: child,
    );
  }
}

class ContainerLogin extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const ContainerLogin({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.fondo2,
        borderRadius: const BorderRadius.all(Radius.circular(17)),
        border: Border.all(color: AppColors.borde2, width: 1),
      ),
      child: child,
    );
  }
}

class BotonLogin extends StatelessWidget {
  final double width;
  final double height;
  final String texto;
  final VoidCallback onPressed;

  const BotonLogin({
    super.key,
    required this.texto,
    required this.onPressed,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.fondo3,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: Border.all(color: AppColors.borde3, width: 1),
          ),
          child: Center(child: Text(texto, style: TextStyles.textoSingLogin)),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String texto;
  final bool isPressed;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.texto,
    required this.isPressed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 53,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isPressed ? AppColors.fondo3 : AppColors.fondo2,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: Border.all(color: AppColors.borde3, width: 1),
          ),
          child: Center(child: Text(texto, style: TextStyles.textoSingLogin)),
        ),
      ),
    );
  }
}

class CircularElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;

  const CircularElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = const Color.fromARGB(171, 255, 255, 255),
    this.borderColor = const Color(0xFF6366F1),
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class IconButtonWithPadding extends StatelessWidget {
  final VoidCallback onPressed;
  final String svgAssetPath;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets buttonPadding;

  const IconButtonWithPadding({
    super.key,
    required this.onPressed,
    required this.svgAssetPath,
    this.padding = const EdgeInsets.only(left: 15),
    this.backgroundColor = const Color(0xFFF3F4F6),
    this.borderColor = const Color(0xE5EBEEF3),
    this.borderWidth = 2,
    this.buttonPadding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CircularElevatedButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        padding: buttonPadding,
        child: SvgPicture.asset(svgAssetPath, width: 24, height: 24),
      ),
    );
  }
}

// Menu cuando se toca el Avatar
class DropMenu extends StatefulWidget {
  const DropMenu({super.key});

  @override
  State<DropMenu> createState() => _DropMenuState();
}

class _DropMenuState extends State<DropMenu> {
  bool _isOpenMenu = false;
  OverlayEntry? _overlayEntry;

  static const BoxDecoration _menuItemDecoration = BoxDecoration(
    color: AppColors.fondoPanico,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppColors.bordePanico,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpenMenu) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpenMenu = true;
    });
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpenMenu = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _closeMenu,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color.fromRGBO(0, 0, 0, 0.33),
                    ),
                  ),
                  Positioned(top: 120, right: 20, child: _buildDropMenu()),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDropMenu() {
    return Column(
      children: [
        _buildMenuItem("assets/images/setting.svg"),
        _buildMenuItem("assets/images/notification.svg"),
      ],
    );
  }

  Widget _buildMenuItem(String svgAssetPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _closeMenu,
        customBorder: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: _menuItemDecoration,
          child: Center(
            child: SvgPicture.asset(svgAssetPath, width: 24, height: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Row(
        children: [
          IconButtonWithPadding(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjustesPerfil()),
              );
            },
            svgAssetPath: "assets/images/alarm.svg",
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: RepaintBoundary(
              child: InkWell(
                onTap: _toggleMenu,
                customBorder: const CircleBorder(),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 44, 42, 42),
                  backgroundImage: AssetImage("assets/images/ass.jpg"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Carousel de imagenes

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final CarouselSliderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: _controller,
      itemCount: CarouselAssets.images.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              CarouselAssets.images[index],
              fit: BoxFit.cover,
              cacheWidth: 400,
              cacheHeight: 250,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        viewportFraction: 0.9,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlayCurve: Curves.easeInOut,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class CircularMenu extends StatelessWidget {
  final List<Widget> items;
  final Widget fabIcon; 

  const CircularMenu({
    super.key,
    required this.items,
    required this.fabIcon, 
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FabCircularMenuPlus(
        alignment: Alignment.bottomCenter,
        ringColor: const Color.fromRGBO(99, 102, 241, 0.63),
        ringDiameter: 240.0,
        ringWidth: 60.0,
        fabSize: 60.12,
        fabElevation: 0,
        fabMargin: const EdgeInsets.all(0),
        ringWidthLimitFactor: 10,
        animationDuration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeOut,
        fabOpenIcon: fabIcon, // 👈 usamos el ícono que manden
        fabColor: AppColors.fondoM,
        children: items,
      ),
    );
  }
}

// --- Semi-circular radial menu (custom) ---

class RadialMenuItem {
  final String iconAsset;
  final VoidCallback onTap;
  final String? tooltip;

  RadialMenuItem({required this.iconAsset, required this.onTap, this.tooltip});
}

class SemiCircularRadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items; // 5 items expected
  final String currentIconAsset; // center icon when closed
  final double radius;
  final Color itemBackground;
  final Color centerBackground;
  final Color ringColor;
  final double itemSize; // diameter of circular item
  final Duration animationDuration;
  final VoidCallback? onCenterDoubleTap; // optional action on center double-tap

  const SemiCircularRadialMenu({
    super.key,
    required this.items,
    required this.currentIconAsset,
    this.radius = 120,
    this.itemBackground = const Color(0xFFF3F4F6),
    this.centerBackground = const Color(0xFFFFFFFF),
    this.ringColor = const Color.fromRGBO(99, 102, 241, 0.20),
    this.itemSize = 56,
    this.animationDuration = const Duration(milliseconds: 350),
    this.onCenterDoubleTap,
  }) : assert(items.length >= 3 && items.length <= 6, 'Use 3-6 items for good spacing');

  @override
  State<SemiCircularRadialMenu> createState() => _SemiCircularRadialMenuState();
}

class _SemiCircularRadialMenuState extends State<SemiCircularRadialMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  bool get _isOpen => _controller.status == AnimationStatus.forward ||
      _controller.status == AnimationStatus.completed ||
      _controller.value > 0.001;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final itemCount = items.length;

    // Angles for semi-circle from left (-pi) to right (0), opening upwards
    final double startAngle = -math.pi; // left
    final double endAngle = 0; // right
    final double step = itemCount == 1 ? 0 : (endAngle - startAngle) / (itemCount - 1);

    return SizedBox(
      height: widget.radius + widget.itemSize + 24,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Optional faint semi-ring background
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final opacity = _anim.value * 1.0;
              return IgnorePointer(
                ignoring: !_isOpen,
                child: Opacity(
                  opacity: opacity,
                  child: CustomPaint(
                    size: Size(widget.radius * 2, widget.radius),
                    painter: _SemiRingPainter(color: widget.ringColor),
                  ),
                ),
              );
            },
          ),

          // Radial items
          ...List.generate(itemCount, (i) {
            final angle = startAngle + step * i;
            return AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final r = widget.radius * _anim.value;
                final dx = r * math.cos(angle);
                final dy = r * math.sin(angle);
                return Transform.translate(
                  offset: Offset(dx, dy - 8), // nudge up a bit
                  child: Opacity(
                    opacity: _anim.value,
                    child: _RadialCircleButton(
                      size: widget.itemSize,
                      background: widget.itemBackground,
                      svgAsset: items[i].iconAsset,
                      onTap: () {
                        // Close then run action to feel snappy
                        _controller.reverse();
                        items[i].onTap();
                      },
                    ),
                  ),
                );
              },
            );
          }),

          // Center toggle button (keeps same icon always, no X)
          _RadialCircleButton(
            size: widget.itemSize + 6,
            background: widget.centerBackground,
            borderColor: const Color(0xFFE5E7EB),
            svgAsset: widget.currentIconAsset,
            onTap: _toggle,
            onDoubleTap: widget.onCenterDoubleTap,
          ),
        ],
      ),
    );
  }
}

class _RadialCircleButton extends StatelessWidget {
  final double size;
  final Color background;
  final Color? borderColor;
  final String svgAsset;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  const _RadialCircleButton({
    required this.size,
    required this.background,
    required this.svgAsset,
    required this.onTap,
    this.borderColor,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: CircleBorder(side: BorderSide(color: borderColor ?? const Color(0xFFE5E7EB), width: 1)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: _safeSvg(svgAsset, width: size * 0.45, height: size * 0.45),
          ),
        ),
      ),
    );

    if (onDoubleTap == null) return button;
    return GestureDetector(onDoubleTap: onDoubleTap, child: button);
  }
}

class _SemiRingPainter extends CustomPainter {
  final Color color;
  const _SemiRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    // Draw upper half of the circle (semi-circle)
    canvas.drawArc(rect, math.pi, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _safeSvg(String path, {double? width, double? height}) {
  try {
    return SvgPicture.asset(path, width: width, height: height);
  } catch (_) {
    return const Icon(Icons.image_not_supported);
  }
}

//Engloba la parte de arriba de buenos dias o buenas noches

class TopFeeling extends StatelessWidget {
  const TopFeeling({super.key});

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return "Buenos días";
    if (hour >= 12 && hour < 18) return "Buenas tardes";
    return "Buenas noches";
  }

  String _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) return "assets/images/sun.svg";
    return "assets/images/moon.svg";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [SvgPicture.asset(_getTimeIcon())]),
        const SizedBox(height: 8),
        Row(
          children: [Text(_getTimeOfDay(), style: TextStyles.textInicioName)],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "¿Cómo te sientes?",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Kantumruy Pro',
                color: AppColors.primary,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//Las caritas
class EmotionButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onTap;

  const EmotionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 110,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.fondo5,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.fondo4, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 20, height: 20),
            const SizedBox(width: 9),
            Text(text, style: TextStyles.textFeeling),
          ],
        ),
      ),
    );
  }
}

//Progreso de la Flor
class FlowerProgress extends StatelessWidget {
  final double progress;

  const FlowerProgress({super.key, required this.progress});

  static const Color _backgroundColor = Color.fromRGBO(240, 232, 241, 0.73);
  static const Color _progressColor = Color.fromRGBO(217, 87, 230, 0.41);

  String _getFlowerAsset(double progress) {
    if (progress < 0.25) return "assets/images/flores/flor1.png";
    if (progress < 0.5) return "assets/images/flores/flor2.png";
    return "assets/images/flores/flor3.png";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: _backgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_progressColor),
            ),
          ),
          Positioned(
            top: 25,
            child: Image.asset(
              _getFlowerAsset(progress),
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: IconButtonWithPadding(
        onPressed: () {},
        svgAssetPath: "assets/images/setting.svg",
      ),
    );
  }
}

class AvatarTop extends StatelessWidget {
  const AvatarTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/images/ass.jpg"),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              ContainerAjustes(
                width: 107,
                height: 34,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Editar", style: TextStyles.textEditar)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContainerAjustes extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;

  static const BoxDecoration _decoration = BoxDecoration(
    color: Color.fromRGBO(224, 231, 255, 0.85),
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );

  const ContainerAjustes({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _decoration,
      child: child,
    );
  }
}
class ContainerC2 extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final Alignment alignment; // 👈 lo guardamos

  static const BoxDecoration _decoration = BoxDecoration(
    color: Color.fromRGBO(224, 231, 255, 0.55),
    borderRadius: BorderRadius.all(Radius.circular(17)),
    border: Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(255, 255, 255, 0.75), width: 1),
    ),
  );

  const ContainerC2({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: _decoration,
      child: child,
    );
  }
}

//Fechas
class SevenDayCalendar extends StatelessWidget {
  final DateTime currentDate;
  final void Function(DateTime)? onDateSelected;

  const SevenDayCalendar({
    super.key,
    required this.currentDate,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = currentDate.subtract(Duration(days: 3 - index));
          final isToday = _isSameDate(date, currentDate);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child:  Container(
                width: 35,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xD8E0E7FF)
                      : const Color.fromARGB(217, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? Color.fromRGBO(255, 255, 255, 0.149)
                        : const Color.fromARGB(105, 255, 255, 255),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w200,
                        color: isToday ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            
          );
        },
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}