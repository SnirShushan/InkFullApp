import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class PostImageScreen extends StatefulWidget {
  final String imgUrl;
  final String posTitle;
  final String isMultipleImages;

  const PostImageScreen({
    Key? key,
    required this.imgUrl,
    required this.isMultipleImages,
    required this.posTitle,
  }) : super(key: key);

  @override
  State<PostImageScreen> createState() => _PostImageScreenState();
}

class _PostImageScreenState extends State<PostImageScreen>
    with SingleTickerProviderStateMixin {
  List<String> imageList = [];
  int _currentIndex = 0;

  // Carousel controller (optional)
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Per-image transform controllers and state
  final List<TransformationController> _controllers = [];
  final List<VoidCallback> _listeners = [];
  final List<double> _scales = [];

  // Animation for double-tap smooth zoom
  late final AnimationController _animController;
  Animation<Matrix4>? _matrixAnimation;

  // Double-tap focal point inside the image widget
  Offset _doubleTapPos = Offset.zero;

  // Flags & constants
  bool _isZoomed = false;
  static const double _doubleTapZoom = 2.0; // Instagram-like double-tap zoom
  static const double _maxScale = 3.0; // pinch max
  static const double _minScale = 1.0;
  static const double _epsilon = 0.005;

  @override
  void initState() {
    super.initState();

    // parse image list
    if (widget.isMultipleImages == "1") {
      final raw = widget.imgUrl;
      if (raw.isNotEmpty) {
        imageList = raw
            .substring(1, raw.length - 1)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    } else {
      imageList = [widget.imgUrl.replaceAll('[', '').replaceAll(']', '')];
    }

    // init animation controller
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    // create controllers and listeners per image
    for (int i = 0; i < imageList.length; i++) {
      final ctrl = TransformationController();
      _controllers.add(ctrl);
      _scales.add(1.0);

      // Listener updates scale value and _isZoomed when the current index changes scale
      final int idx = i;
      void listener() {
        final scale = ctrl.value.getMaxScaleOnAxis();
        // clamp tiny floating errors
        _scales[idx] = (scale.isFinite) ? scale : 1.0;

        // If the currently visible slide changed scale, update _isZoomed so carousel physics toggle
        if (idx == _currentIndex) {
          final nowZoomed = (_scales[_currentIndex] - 1.0) > _epsilon;
          if (nowZoomed != _isZoomed) {
            setState(() => _isZoomed = nowZoomed);
          } else {
            // still call setState to update panEnabled etc if necessary
            setState(() {});
          }
        }
      }

      ctrl.addListener(listener);
      _listeners.add(listener);
    }
  }

  @override
  void dispose() {
    // remove listeners and dispose controllers
    for (int i = 0; i < _controllers.length; i++) {
      try {
        _controllers[i].removeListener(_listeners[i]);
      } catch (_) {}
      _controllers[i].dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  // Animate matrix from current -> target for smooth double-tap transitions
  Future<void> _animateToMatrix(
      TransformationController controller, Matrix4 target) async {
    final begin = controller.value;
    _matrixAnimation = Matrix4Tween(begin: begin, end: target).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    void tick() {
      controller.value = _matrixAnimation!.value;
    }

    _animController.removeListener(tick);
    _animController.addListener(tick);
    await _animController.forward(from: 0.0);
    _animController.removeListener(tick);
    _matrixAnimation = null;
  }

  // Double-tap toggles between 1.0 and _doubleTapZoom, animating smoothly
  Future<void> _handleDoubleTap(int index) async {
    final controller = _controllers[index];
    final currentScale = controller.value.getMaxScaleOnAxis();

    // Zoom OUT if currently zoomed (use epsilon)
    if ((currentScale - 1.0).abs() > _epsilon) {
      await _animateToMatrix(controller, Matrix4.identity());
      _scales[index] = 1.0;
      if (index == _currentIndex) {
        setState(() => _isZoomed = false);
      } else {
        setState(() {});
      }
      return;
    }

    // Zoom IN: compute a target matrix that scales around the tapped point.
    // _doubleTapPos is in local widget coords (GestureDetector onDoubleTapDown)
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size viewport = box.size;

    // Because we use a larger "virtual canvas" for InteractiveViewer child (see build),
    // we compute the translation as a heuristic to keep tapped point under the finger.
    final double zoom = _doubleTapZoom;
    final dx = _doubleTapPos.dx;
    final dy = _doubleTapPos.dy;

    // target matrix: translate then scale
    final Matrix4 target = Matrix4.identity()
      ..translate(-dx * (zoom - 1), -dy * (zoom - 1))
      ..scale(zoom);

    await _animateToMatrix(controller, target);

    _scales[index] = zoom;
    if (index == _currentIndex) {
      setState(() => _isZoomed = true);
    } else {
      setState(() {});
    }
  }

  // Build zoomable image: uses InteractiveViewer but provides a larger virtual canvas
  Widget _buildZoomImage(String url, int index) {
    final controller = _controllers[index];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (details) {
        // store local position relative to this widget (used for zoom focal)
        _doubleTapPos = details.localPosition;
      },
      onDoubleTap: () => _handleDoubleTap(index),
      child: InteractiveViewer(
        transformationController: controller,
        minScale: _minScale,
        maxScale: _maxScale,
        // keep panEnabled true so panning works when zoomed
        panEnabled: true,
        scaleEnabled: true,
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(200),

        // Child is a larger virtual canvas so scaling has room, but FittedBox keeps visual appearance exact.
        child: LayoutBuilder(builder: (context, constraints) {
          // virtual canvas size (2x to allow room for scaling and panning)
          final double w = constraints.maxWidth * 2;
          final double h = constraints.maxHeight * 2;

          return Center(
            child: SizedBox(
              width: w,
              height: h,
              child: FittedBox(
                fit: BoxFit.contain,
                // keeps the image visually the same before zoom
                child: CachedNetworkImage(
                  imageUrl: WebService.resolveImageUrl(url),
                  placeholder: (_, __) => Center(
                    child: Transform.scale(
                      scale: 0.1, // 2x size
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // When zoomed, disable page scroll so panning isn't intercepted.
    final ScrollPhysics sliderPhysics = _isZoomed
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics();

    return Scaffold(
      appBar: buildappBarwithback(size: size, title: widget.posTitle),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                scrollPhysics: sliderPhysics,
                onPageChanged: (index, reason) {
                  setState(() {
                    // reset previous image zoom
                    _controllers[_currentIndex].value = Matrix4.identity();
                    _scales[_currentIndex] = 1.0;

                    // reset new image zoom
                    _controllers[index].value = Matrix4.identity();
                    _scales[index] = 1.0;

                    _currentIndex = index;
                    _isZoomed = false;
                  });
                },
              ),
              items: List.generate(
                imageList.length,
                (i) => _buildZoomImage(imageList[i], i),
              ),
            ),
          ),

          // INDICATORS
          if (imageList.length > 1)
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageList.length,
                  (i) => Container(
                    width: _currentIndex == i ? 32.0 : 28.0,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        color: (_currentIndex == i
                            ? titleTextWhiteColor
                            : titleTextWhiteColor.withOpacity(0.4))),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
