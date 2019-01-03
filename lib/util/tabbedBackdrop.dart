import 'dart:math' as math;

import 'package:flutter/material.dart';

const double kFrontHeadingHeight = 32.0; // front layer beveled rectangle
const double kFrontClosedHeight = 92.0; // front layer height when closed
const double _kBackAppBarHeight = 48.0; // back layer (options) appbar height
// The size of the front layer heading's left and right beveled corners.
final Animatable<BorderRadius> _kFrontHeadingRoundRadius = BorderRadiusTween(
  begin: const BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  ),
  end: const BorderRadius.only(
    topLeft: Radius.circular(kFrontHeadingHeight),
    topRight: Radius.circular(kFrontHeadingHeight),
  ),
);

class _TappableWhileStatusIs extends StatefulWidget {
  const _TappableWhileStatusIs(
    this.status, {
    Key key,
    this.controller,
    this.child,
  }) : super(key: key);

  final AnimationController controller;
  final AnimationStatus status;
  final Widget child;

  @override
  _TappableWhileStatusIsState createState() => _TappableWhileStatusIsState();
}

class _TappableWhileStatusIsState extends State<_TappableWhileStatusIs> {
  bool _active;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_handleStatusChange);
    _active = widget.controller.status == widget.status;
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    final bool value = widget.controller.status == widget.status;
    if (_active != value) {
      setState(() {
        _active = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_active,
      child: widget.child,
    );
  }
}

class _CrossFadeTransition extends StatelessWidget {
  final Animation<double> progress;

  const _CrossFadeTransition({
    Key key,
    this.alignment = Alignment.center,
    this.progress,
    this.child0,
    this.child1,
  }) : super(key: key);

  final AlignmentGeometry alignment;
  final Widget child0;
  final Widget child1;

  @override
  Widget build(BuildContext context) {
    final double opacity1 = CurvedAnimation(
      parent: ReverseAnimation(progress),
      curve: const Interval(0.5, 1.0),
    ).value;

    final double opacity2 = CurvedAnimation(
      parent: progress,
      curve: const Interval(0.5, 1.0),
    ).value;

    if (opacity1 == 0.0) {
      return Opacity(
        opacity: opacity2,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: child0,
        ),
      );
    } else if (opacity2 == 0.0) {
      return Opacity(
        opacity: opacity1,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: child1,
        ),
      );
    } else
      return Stack(
        alignment: alignment,
        children: <Widget>[
          Opacity(
            opacity: opacity1,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: child1,
            ),
          ),
          Opacity(
            opacity: opacity2,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: child0,
            ),
          ),
        ],
      );
  }
}

class TabbedBackdrop extends StatefulWidget {
  const TabbedBackdrop({
    this.backdrops,
    this.tabs,
    this.initialIndex = 0,
    Key key,
  }) : super(key: key);

  final List<BackdropComponent> backdrops;
  final List<Tab> tabs;
  final int initialIndex;

  @override
  TabbedBackdropState createState() => TabbedBackdropState();
}

class TabbedBackdropState extends State<TabbedBackdrop>
    with TickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;
  Animation<double> _frontOpacity;
  TabController _tabController;

  static final Animatable<double> _frontOpacityTween =
      Tween<double>(begin: 0.2, end: 1.0).chain(
          CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeInOut)));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
    _frontOpacity = _controller.drive(_frontOpacityTween);

    _tabController = new TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _tabController.animation.addListener(() => this.setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get _backdropHeight {
    // Warning: this can be safely called from the event handlers but it may
    // not be called at build time.
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return math.max(
        0.0, renderBox.size.height - _kBackAppBarHeight - kFrontClosedHeight);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -=
        details.primaryDelta / (_backdropHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }

  void toggleFrontLayer() {
    final AnimationStatus status = _controller.status;
    final bool isOpen = status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
    _controller.fling(velocity: isOpen ? -2.0 : 2.0);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> frontRelativeRect =
        _controller.drive(RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, constraints.biggest.height - kFrontClosedHeight, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, _kBackAppBarHeight, 0.0, 0.0),
    ));

    final List<Widget> layers = <Widget>[
      // Back layer
      Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: kFrontHeadingHeight),
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 52.0),
              controller: _tabController,
              tabs: widget.tabs,
              indicatorColor: Colors.white,
            ),
          ),
          _controller.status != AnimationStatus.completed
              ? Expanded(child: _calculateBackpanel())
              : const SizedBox(),
        ],
      ),
      PositionedTransition(
        rect: frontRelativeRect,
        child: TabBarView(
          controller: _tabController,
          children: widget.backdrops.map((widget) {
            return Padding(
              padding: EdgeInsets.only(top: widget.frontPadding),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return PhysicalShape(
                    elevation: 12.0,
                    color: Colors.white,
                    //Theme.of(context).canvasColor,
                    clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                        borderRadius: (widget.borderRadiusAnimation ??
                                _kFrontHeadingRoundRadius)
                            .transform(_controller.value),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  );
                },
                child: Stack(
                  children: [
                    _TappableWhileStatusIs(
                      AnimationStatus.completed,
                      controller: _controller,
                      child: FadeTransition(
                        opacity: _frontOpacity,
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.tight,
                              child: widget.frontLayer,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildHeader(widget.frontHeading),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ];

    return Container(
      color: _calculateColor(),
      child: SafeArea(
        child: Stack(
          key: _backdropKey,
          children: layers,
        ),
      ),
    );
  }

  Widget _buildHeader(Widget header) {
    return Align(
      alignment: Alignment.topCenter,
      child: ExcludeSemantics(
        child: Container(
          height: kFrontHeadingHeight + 1,
          alignment: Alignment.topLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: toggleFrontLayer,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              color: Colors.white70,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: header,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _CrossFadeTransition _calculateFadeTransition(Widget w1, Widget w2) {
    return _CrossFadeTransition(
      child0: w1,
      child1: w2,
      progress: mapAnimation(),
    );
  }

  Animation<double> mapAnimation() {
    double truncatedValue = _tabController.animation.value.truncateToDouble();

    Animation<double> animation = Tween<double>(
      begin: 0.0 - truncatedValue,
      end: 1.0 - truncatedValue,
    ).animate(_tabController.animation);

    return animation;
  }

  Color _calculateColor() {
    Animation<double> animation = mapAnimation();

    return Color.lerp(
      widget.backdrops[_tabController.animation.value.floor()].backgroundColor,
      widget.backdrops[_tabController.animation.value.ceil()].backgroundColor,
      animation.value,
    );
  }

  Widget _calculateBackpanel() {
    return _calculateFadeTransition(
      widget.backdrops[_tabController.animation.value.ceil()].backLayer,
      widget.backdrops[_tabController.animation.value.floor()].backLayer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildStack);
  }
}

class BackdropComponent {
  final Widget frontLayer;
  final Widget frontHeading;
  final Widget backLayer;
  final ColorSwatch backgroundColor;
  final double frontPadding;
  final Animatable<BorderRadius> borderRadiusAnimation;

  BackdropComponent({
    this.borderRadiusAnimation,
    this.frontPadding = 0.0,
    @required this.frontLayer,
    @required this.frontHeading,
    @required this.backLayer,
    @required this.backgroundColor,
  })  : assert(frontHeading != null),
        assert(frontPadding != null),
        assert(backLayer != null),
        assert(backgroundColor != null),
        assert(frontLayer != null);
}
