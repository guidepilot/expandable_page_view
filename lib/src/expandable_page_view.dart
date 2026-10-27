library expandable_page_view;

import 'dart:math';

import 'package:expandable_page_view/src/expandable_page_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef WidgetBuilder = Widget Function(BuildContext context, int index);

class ExpandablePageView extends StatefulWidget {
  /// List of widgets to display
  ///
  /// Corresponds to Material's PageView's children parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final List<Widget>? children;

  /// Number of widgets to display
  ///
  /// Corresponds to Material PageView's itemCount parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final int? itemCount;

  /// Item builder function
  ///
  /// Corresponds to Material's PageView's itemBuilder parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final WidgetBuilder? itemBuilder;

  /// An object that can be used to control the position to which this page view is scrolled.
  ///
  /// Corresponds to Material's PageView's controller parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final PageController? controller;

  /// Called whenever the page in the center of the viewport changes.
  ///
  /// Corresponds to Material's PageView's onPageChanged parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final ValueChanged<int>? onPageChanged;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// Corresponds to Material's PageView's reverse parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool reverse;

  /// Duration of PageView resize animation upon page change
  ///
  /// Defaults to [100 milliseconds]
  final Duration animationDuration;

  /// Curve use for PageView resize animation upon page change
  ///
  /// Defaults to [Curves.easeInOutCubic]
  final Curve animationCurve;

  /// How the page view should respond to user input.
  ///
  /// Corresponds to Material's PageView's physics parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final ScrollPhysics? physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  ///
  /// Corresponds to Material's PageView's pageSnapping parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool pageSnapping;

  /// Determines the way that drag start behavior is handled.
  ///
  /// Corresponds to Material's PageView's dragStartBehavior parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final DragStartBehavior dragStartBehavior;

  /// Controls whether the widget's pages will respond to [RenderObject.showOnScreen], which will allow for implicit accessibility scrolling.
  ///
  /// Corresponds to Material's PageView's allowImplicitScrolling parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool allowImplicitScrolling;

  /// Restoration ID to save and restore the scroll offset of the scrollable.
  ///
  /// Corresponds to Material's PageView's restorationId parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final String? restorationId;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Corresponds to Material's PageView's clipBehavior parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final Clip clipBehavior;

  /// Whether to animate the first page displayed by this widget.
  ///
  /// By default (false) [ExpandablePageView] will resize to the size of it's
  /// initially displayed page without any animation.
  final bool animateFirstPage;

  /// Determines the alignment of the content when animating. Useful when building centered or bottom-aligned PageViews.
  final Alignment alignment;

  /// The estimated size of displayed pages.
  ///
  /// This property can be used to indicate how big a page will be more or less.
  /// By default (0.0) all pages will have their initial sizes set to 0.0
  /// until they report that their size changed, which will result in
  /// [ExpandablePageView] size animation. This can lead to a behaviour
  /// when after changing the page, [ExpandablePageView] will first shrink to 0.0
  /// and then animate to the size of the page.
  ///
  /// For example: If there is certainty that most pages displayed by [ExpandablePageView]
  /// will vary from 200 to 600 in size, then [estimatedPageSize] could be set to some
  /// value in that range, to at least partially remove the "shrink and expand" effect.
  ///
  /// Setting it to a value much bigger than most pages' sizes might result in a
  /// reversed - "expand and shrink" - effect.
  final double estimatedPageSize;

  ///A ScrollBehavior that will be applied to this widget individually.
  //
  // Defaults to null, wherein the inherited ScrollBehavior is copied and modified to alter the viewport decoration, like Scrollbars.
  //
  // ScrollBehaviors also provide ScrollPhysics. If an explicit ScrollPhysics is provided in physics, it will take precedence, followed by scrollBehavior, and then the inherited ancestor ScrollBehavior.
  //
  // The ScrollBehavior of the inherited ScrollConfiguration will be modified by default to not apply a Scrollbar.
  final ScrollBehavior? scrollBehavior;

  ///The axis along which the page view scrolls.
  //
  // Defaults to Axis.horizontal.
  final Axis scrollDirection;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [PageController.viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  ///
  /// If [PageController.viewportFraction] >= 1.0, this property has no effect.
  ///
  /// This property defaults to true and must not be null.
  final bool padEnds;

  /// Whether the page view should loop infinitely.
  ///
  /// When set to true, the page view will cycle through pages infinitely
  /// in both directions. Swiping past the last page will show the first page,
  /// and swiping before the first page will show the last page.
  ///
  /// The [onPageChanged] callback will receive the actual page index (0 to itemCount-1),
  /// not the virtual index used internally for infinite scrolling.
  ///
  /// To programmatically control the page view in loop mode, use
  /// [ExpandablePageController]:
  ///
  /// ```dart
  /// final controller = ExpandablePageController(itemCount: 5);
  ///
  /// ExpandablePageView(
  ///   controller: controller,
  ///   loop: true,
  ///   children: [...],
  /// );
  ///
  /// // Navigate programmatically
  /// controller.jumpToPage(3);
  /// controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  /// ```
  ///
  /// If a regular [PageController] is provided instead, it will only be used
  /// to read [PageController.initialPage], [PageController.viewportFraction],
  /// and [PageController.keepPage]. The regular controller will not be attached
  /// to the PageView.
  ///
  /// Defaults to false.
  final bool loop;

  /// Whether the page view keeps the height of the tallest page it has
  /// measured, instead of resizing to each page as it is shown.
  ///
  /// Sizes are only sampled once a transition settles, so a page briefly laid
  /// out at the wrong width mid-swipe (soft-wrapping much taller than it really
  /// is) cannot inflate the height.
  ///
  /// Defaults to false.
  final bool expandToMaxSize;

  ExpandablePageView({
    required List<Widget> children,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeInOutCubic,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.animateFirstPage = false,
    this.estimatedPageSize = 0.0,
    this.alignment = Alignment.topCenter,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.padEnds = true,
    this.loop = false,
    this.expandToMaxSize = false,
    Key? key,
  })  : assert(estimatedPageSize >= 0.0),
        assert(!loop || children.isNotEmpty, 'children must not be empty when loop is true'),
        assert(
          loop || controller is! ExpandablePageController,
          'ExpandablePageController should only be used with loop: true',
        ),
        children = children,
        itemBuilder = null,
        itemCount = null,
        super(key: key);

  ExpandablePageView.builder({
    required int itemCount,
    required WidgetBuilder itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeInOutCubic,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.animateFirstPage = false,
    this.estimatedPageSize = 0.0,
    this.alignment = Alignment.topCenter,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.padEnds = true,
    this.loop = false,
    this.expandToMaxSize = false,
    Key? key,
  })  : assert(estimatedPageSize >= 0.0),
        assert(!loop || itemCount > 0, 'itemCount must be greater than 0 when loop is true'),
        assert(
          loop || controller is! ExpandablePageController,
          'ExpandablePageController should only be used with loop: true',
        ),
        children = null,
        itemCount = itemCount,
        itemBuilder = itemBuilder,
        super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  late PageController _pageController;
  late List<double> _sizes;
  int _currentPage = 0;
  int _previousPage = 0;
  bool _shouldDisposePageController = false;
  bool _firstPageLoaded = false;
  double? _initialSize;
  // Latest size each real page has reported, whether or not it has been
  // committed into [_sizes]. In expandToMaxSize mode, reports made while a
  // transition is in progress are parked here and only committed once it ends.
  late List<double?> _lastReportedSizes;
  // The cross-axis extent (the width, for a horizontal page view) each page was
  // measured at, alongside [_sizes] / [_lastReportedSizes]. Null: not measured
  // (an estimate, or a placeholder carried over from another page).
  late List<double?> _measuredCrossExtents;
  late List<double?> _lastReportedCrossExtents;
  // The cross-axis extent of the latest committed measurement — the page
  // view's current width, for a horizontal one.
  double? _currentCrossExtent;
  // True between a ScrollStart and ScrollEnd from the page view itself.
  bool _isScrolling = false;

  /// Tallest page — used as the fixed height in expandToMaxSize mode.
  ///
  /// Only pages measured at the current cross-axis extent count, besides the
  /// unmeasured estimates: a page's height depends on its width, so one measured
  /// before a rotation (or a split-screen resize) says nothing about it now. Such
  /// a page counts again once it has been laid out at the new width — like an
  /// unvisited page on first appearance.
  double get _maxChildSize {
    double maxSize = 0;
    for (var i = 0; i < _sizes.length; i++) {
      final measuredAt = _measuredCrossExtents.elementAtOrNull(i);
      if (measuredAt != null && measuredAt != _currentCrossExtent) continue;
      maxSize = max(maxSize, _sizes[i]);
    }
    return maxSize;
  }

  void _resetCrossExtents() {
    _measuredCrossExtents = List<double?>.filled(_sizes.length, null, growable: true);
    _lastReportedCrossExtents = List<double?>.filled(_sizes.length, null, growable: true);
  }

  /// The actual number of items (not virtual).
  int get _itemCount => widget.itemCount ?? widget.children!.length;

  /// Converts a virtual index (used in infinite scroll) to a real index (0 to _itemCount-1).
  int _realIndex(int virtualIndex) {
    if (!widget.loop) return virtualIndex;
    final count = _itemCount;
    // Handle negative indices properly
    return ((virtualIndex % count) + count) % count;
  }

  /// The initial page for the PageController in loop mode.
  /// Starts at a large offset to allow scrolling in both directions.
  int _loopInitialPageFor(int realPage) {
    return (ExpandablePageController.loopMultiplier * _itemCount) + realPage;
  }

  /// Creates a PageController for loop mode with the given initial page.
  PageController _createLoopController(int initialRealPage) {
    return PageController(
      initialPage: _loopInitialPageFor(initialRealPage),
      viewportFraction: widget.controller?.viewportFraction ?? 1.0,
      keepPage: widget.controller?.keepPage ?? true,
    );
  }

  /// Creates a PageController for non-loop mode.
  PageController _createStandardController(int initialPage) {
    return widget.controller ?? PageController(initialPage: initialPage);
  }

  double get _currentSize {
    final viewportFraction = _pageController.viewportFraction;
    if (viewportFraction >= 1.0) {
      return _sizes[_realIndex(_currentPage)];
    }
    // When viewportFraction < 1.0, multiple pages are visible
    // Calculate the range of visible pages and return the max size
    return _maxVisibleSizeForPage(_currentPage);
  }

  double get _previousSize {
    // For the first page animation, use the initial estimated size
    // so we animate from estimatedPageSize to the actual measured size.
    // Only do this if animateFirstPage is true.
    if (!_firstPageLoaded && _initialSize != null && widget.animateFirstPage) {
      return _initialSize!;
    }
    final viewportFraction = _pageController.viewportFraction;
    if (viewportFraction >= 1.0) {
      return _sizes[_realIndex(_previousPage)];
    }
    // With viewportFraction < 1.0, use max of visible pages for previous state too
    return _maxVisibleSizeForPage(_previousPage);
  }

  /// Returns the maximum size among all visible pages when viewportFraction < 1.0.
  /// Calculates how many pages are visible on each side based on the viewportFraction:
  /// - viewportFraction 0.5: 1 page visible on each side
  /// - viewportFraction 0.33: 2 pages visible on each side
  /// - viewportFraction 0.25: 2 pages visible on each side
  double _maxVisibleSizeForPage(int virtualPage) {
    if (_sizes.isEmpty) return 0;

    final viewportFraction = _pageController.viewportFraction;
    final visibleOnEachSide = ((1 - viewportFraction) / (2 * viewportFraction)).round();

    double maxSize = 0;
    for (int i = -visibleOnEachSide; i <= visibleOnEachSide; i++) {
      final adjacentVirtualPage = virtualPage + i;

      // In non-loop mode, skip pages outside valid range
      if (!widget.loop) {
        if (adjacentVirtualPage < 0 || adjacentVirtualPage >= _sizes.length) {
          continue;
        }
      }

      final realIdx = _realIndex(adjacentVirtualPage);
      if (_sizes[realIdx] > maxSize) {
        maxSize = _sizes[realIdx];
      }
    }
    return maxSize;
  }

  bool get isBuilder => widget.itemBuilder != null;

  bool get _isHorizontalScroll => widget.scrollDirection == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _sizes = _prepareSizes();
    _lastReportedSizes = List<double?>.filled(_sizes.length, null, growable: true);
    _resetCrossExtents();
    _initializePageController();
    _pageController.addListener(_updatePage);
    _initialSize = widget.estimatedPageSize;
  }

  void _initializePageController() {
    if (widget.loop) {
      final expandableController = widget.controller is ExpandablePageController
          ? widget.controller as ExpandablePageController
          : null;

      if (expandableController != null) {
        // User provided an ExpandablePageController — use it directly
        expandableController.itemCount = _itemCount;
        _pageController = expandableController;
        _shouldDisposePageController = false;
        _currentPage = _pageController.initialPage;
        _previousPage = _currentPage;
      } else {
        // No controller or regular PageController — create internal one
        final userInitialPage = widget.controller?.initialPage ?? 0;
        _pageController = _createLoopController(userInitialPage);
        _shouldDisposePageController = true;
        _currentPage = _loopInitialPageFor(userInitialPage);
        _previousPage = _currentPage;
      }
    } else {
      _pageController = _createStandardController(0);
      _shouldDisposePageController = widget.controller == null;
      _currentPage = _pageController.initialPage.clamp(0, max(0, _sizes.length - 1));
      _previousPage = max(0, _currentPage - 1);
    }
  }

  @override
  void didUpdateWidget(covariant ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loop property change
    if (oldWidget.loop != widget.loop) {
      _handleLoopChange(oldWidget);
      if (_shouldReinitializeHeights(oldWidget)) {
        _reinitializeSizes();
      }
      return;
    }

    if (oldWidget.controller != widget.controller) {
      if (widget.loop &&
          (widget.controller is ExpandablePageController ||
              oldWidget.controller is ExpandablePageController)) {
        _handleLoopControllerChange();
      } else if (!widget.loop) {
        _pageController.removeListener(_updatePage);
        if (_shouldDisposePageController) {
          _pageController.dispose();
        }
        _pageController = widget.controller ?? PageController();
        _pageController.addListener(_updatePage);
        _shouldDisposePageController = widget.controller == null;
      }
    }

    // Update itemCount on ExpandablePageController when children change
    if (widget.loop && _pageController is ExpandablePageController) {
      (_pageController as ExpandablePageController).itemCount = _itemCount;
    }

    if (_shouldReinitializeHeights(oldWidget)) {
      _reinitializeSizes();
    }
  }

  /// Handles the transition when loop property changes.
  void _handleLoopChange(ExpandablePageView oldWidget) {
    final currentRealPage = _realIndex(_currentPage);
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }

    if (widget.loop) {
      final expandableController = widget.controller is ExpandablePageController
          ? widget.controller as ExpandablePageController
          : null;

      if (expandableController != null) {
        // Compute actual real page using old loop state, since _realIndex
        // uses widget.loop which already reflects the new value.
        final actualRealPage = oldWidget.loop
            ? (((_currentPage % _itemCount) + _itemCount) % _itemCount)
            : _currentPage;
        final oldSize = _sizes[actualRealPage.clamp(0, max(0, _sizes.length - 1))];

        // Re-use the user's ExpandablePageController.
        // Page resets to controller's initialPage — acceptable for a loop toggle.
        expandableController.itemCount = _itemCount;
        _pageController = expandableController;
        _shouldDisposePageController = false;
        _currentPage = _pageController.initialPage;
        _previousPage = _currentPage;

        // Preserve old page size for the new page if it hasn't been measured,
        // preventing the widget from collapsing to zero height.
        final newRealPage = _realIndex(_currentPage);
        if (_sizes[newRealPage] == 0.0 || _sizes[newRealPage] == widget.estimatedPageSize) {
          _sizes[newRealPage] = oldSize;
        }

        // The PageView reuses scroll positions, so initialPage alone doesn't
        // move to the correct page. Jump after the controller is attached.
        final targetRealPage = newRealPage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(targetRealPage);
          }
        });
      } else {
        _pageController = _createLoopController(currentRealPage);
        _shouldDisposePageController = true;
        _currentPage = _loopInitialPageFor(currentRealPage);
        _previousPage = _currentPage;
      }
    } else {
      // When toggling to non-loop mode, always create an internal standard
      // controller. Don't use ExpandablePageController here because its
      // initialPage is a virtual index that doesn't work in non-loop mode.
      _pageController = PageController(initialPage: currentRealPage);
      _shouldDisposePageController = true;
      _currentPage = currentRealPage.clamp(0, max(0, _sizes.length - 1));
      _previousPage = _currentPage;
    }

    _pageController.addListener(_updatePage);
  }

  /// Handles controller change while in loop mode.
  void _handleLoopControllerChange() {
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }

    final oldSize = _sizes[_realIndex(_currentPage)];
    _previousPage = _currentPage;

    final expandableController = widget.controller is ExpandablePageController
        ? widget.controller as ExpandablePageController
        : null;

    if (expandableController != null) {
      expandableController.itemCount = _itemCount;
      _pageController = expandableController;
      _shouldDisposePageController = false;
      _currentPage = _pageController.initialPage;
    } else {
      final userInitialPage = widget.controller?.initialPage ?? 0;
      _pageController = _createLoopController(userInitialPage);
      _shouldDisposePageController = true;
      _currentPage = _loopInitialPageFor(userInitialPage);
    }

    // Use the old page's measured size as a placeholder for the new page
    // if it hasn't been measured yet, preventing the widget from collapsing
    // to zero height before the new page can report its actual size.
    final newRealPage = _realIndex(_currentPage);
    if (_sizes[newRealPage] == 0.0 || _sizes[newRealPage] == widget.estimatedPageSize) {
      _sizes[newRealPage] = oldSize;
    }

    _pageController.addListener(_updatePage);

    // The PageView reuses scroll positions, so initialPage alone doesn't
    // move to the correct page. Jump after the controller is attached.
    if (expandableController != null) {
      final targetRealPage = _realIndex(_currentPage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(targetRealPage);
        }
      });
    } else {
      final targetVirtualPage = _currentPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(targetVirtualPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageView = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: _buildPageView(),
    );
    if (widget.expandToMaxSize) {
      final maxSize = _maxChildSize;
      return SizedBox(
        height: _isHorizontalScroll ? maxSize : null,
        width: !_isHorizontalScroll ? maxSize : null,
        child: pageView,
      );
    }
    return TweenAnimationBuilder<double>(
      curve: widget.animationCurve,
      duration: _getDuration(),
      tween: Tween<double>(begin: _previousSize, end: _currentSize),
      builder: (context, value, child) => SizedBox(
        height: _isHorizontalScroll ? value : null,
        width: !_isHorizontalScroll ? value : null,
        child: child,
      ),
      child: pageView,
    );
  }

  bool _shouldReinitializeHeights(ExpandablePageView oldWidget) {
    if (oldWidget.itemBuilder != null && isBuilder) {
      return oldWidget.itemCount != widget.itemCount;
    }
    return oldWidget.children?.length != widget.children?.length;
  }

  void _reinitializeSizes() {
    final realCurrentPage = _realIndex(_currentPage);
    final currentPageSize = _sizes[realCurrentPage];

    final estimatedSizes = _prepareSizes();
    for (int i = 0; i < estimatedSizes.length; i++) {
      estimatedSizes[i] = _sizes.elementAtOrNull(i) ?? estimatedSizes[i];
    }
    final measuredCrossExtents = List<double?>.filled(estimatedSizes.length, null, growable: true);
    for (int i = 0; i < measuredCrossExtents.length; i++) {
      measuredCrossExtents[i] = _measuredCrossExtents.elementAtOrNull(i);
    }
    _sizes = estimatedSizes;
    _lastReportedSizes = List<double?>.filled(_sizes.length, null, growable: true);
    _measuredCrossExtents = measuredCrossExtents;
    _lastReportedCrossExtents = List<double?>.filled(_sizes.length, null, growable: true);

    if (!widget.loop && realCurrentPage >= _sizes.length) {
      final differenceFromPreviousToCurrent = _previousPage - _currentPage;
      _currentPage = _sizes.length - 1;
      widget.onPageChanged?.call(_currentPage);

      _previousPage = (_currentPage + differenceFromPreviousToCurrent).clamp(0, _sizes.length - 1);
    }

    if (!widget.loop) {
      _previousPage = _previousPage.clamp(0, _sizes.length - 1);
    }
    _sizes[_realIndex(_currentPage)] = currentPageSize;
  }

  Duration _getDuration() {
    if (_firstPageLoaded) {
      return widget.animationDuration;
    }
    return widget.animateFirstPage ? widget.animationDuration : Duration.zero;
  }

  /// Handles onPageChanged callback, converting virtual index to real index in loop mode.
  void _handlePageChanged(int virtualIndex) {
    final realIndex = _realIndex(virtualIndex);
    widget.onPageChanged?.call(realIndex);
  }

  Widget _buildPageView() {
    if (isBuilder || widget.loop) {
      return PageView.builder(
        controller: _pageController,
        itemBuilder: _itemBuilder,
        itemCount: widget.loop ? null : widget.itemCount,
        onPageChanged: _handlePageChanged,
        reverse: widget.reverse,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        dragStartBehavior: widget.dragStartBehavior,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        scrollBehavior: widget.scrollBehavior,
        scrollDirection: widget.scrollDirection,
        padEnds: widget.padEnds,
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: _handlePageChanged,
      reverse: widget.reverse,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      dragStartBehavior: widget.dragStartBehavior,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      scrollBehavior: widget.scrollBehavior,
      scrollDirection: widget.scrollDirection,
      padEnds: widget.padEnds,
      children: _sizeReportingChildren(),
    );
  }

  List<double> _prepareSizes() {
    return List.filled(_itemCount, widget.estimatedPageSize);
  }

  void _updatePage() {
    final newPage = _pageController.page!.round();
    if (_currentPage != newPage) {
      setState(() {
        _firstPageLoaded = true;
        _previousPage = _currentPage;
        _currentPage = newPage;
      });
    }
    // A transition that just settled parked its final sizes while it was
    // moving (expandToMaxSize mode); flush them now that we are at rest.
    _commitSizesIfSettled();
  }

  /// Whether the page view is at rest (not mid-transition). Only meaningful for
  /// expandToMaxSize mode; driven by [ScrollStartNotification] /
  /// [ScrollEndNotification] from the page view.
  bool get _isSettled => !_isScrolling;

  /// Intercepts the page view's own scroll notifications (depth 0 only, so a
  /// scrollable *inside* a page doesn't count) to track transition state and
  /// flush parked sizes once a transition ends.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _isScrolling = true;
    } else if (notification is ScrollEndNotification) {
      _isScrolling = false;
      // Flush after the settled frame has laid the page out at its final width.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _commitSizesIfSettled();
      });
    }
    return false;
  }

  /// Records a real page's latest measured size. In expandToMaxSize mode a size
  /// reported mid-transition is parked until the scroll settles; otherwise it
  /// is committed immediately (1.3.0's default per-page sizing).
  void _reportSize(int realIndex, Size size, {required bool isCurrentPage}) {
    if (realIndex < 0 || realIndex >= _lastReportedSizes.length) return;
    _lastReportedSizes[realIndex] = _isHorizontalScroll ? size.height : size.width;
    _lastReportedCrossExtents[realIndex] = _isHorizontalScroll ? size.width : size.height;
    if (widget.expandToMaxSize && !_isSettled) return;
    final changed = _drainReportedSizes();
    final firstLoadPending = isCurrentPage && !_firstPageLoaded;
    if (changed || firstLoadPending) {
      setState(() {
        if (firstLoadPending) _firstPageLoaded = true;
      });
    }
  }

  /// Copies parked reports into [_sizes]; returns whether anything changed.
  bool _drainReportedSizes() {
    var changed = false;
    for (var i = 0; i < _sizes.length; i++) {
      final reported = _lastReportedSizes[i];
      if (reported != null && _sizes[i] != reported) {
        _sizes[i] = reported;
        changed = true;
      }
      final crossExtent = _lastReportedCrossExtents[i];
      if (crossExtent != null) {
        if (_measuredCrossExtents[i] != crossExtent) {
          _measuredCrossExtents[i] = crossExtent;
          changed = true;
        }
        if (_currentCrossExtent != crossExtent) {
          _currentCrossExtent = crossExtent;
          changed = true;
        }
      }
    }
    return changed;
  }

  void _commitSizesIfSettled() {
    if (widget.expandToMaxSize && !_isSettled) return;
    if (_drainReportedSizes()) setState(() {});
  }

  Widget _itemBuilder(BuildContext context, int virtualIndex) {
    final realIndex = _realIndex(virtualIndex);
    final child = widget.loop && !isBuilder
        ? widget.children![realIndex]
        : widget.itemBuilder!(context, realIndex);

    return _SizeReportingChild(
      onSizeChange: (size) => _reportSize(
        realIndex,
        size,
        isCurrentPage: virtualIndex == _currentPage,
      ),
      alignment: widget.alignment,
      scrollDirection: widget.scrollDirection,
      minSize: widget.expandToMaxSize ? _maxChildSize : 0,
      child: child,
    );
  }

  List<Widget> _sizeReportingChildren() {
    return [
      for (int i = 0; i < widget.children!.length; i++)
        _SizeReportingChild(
          onSizeChange: (size) => _reportSize(
            i,
            size,
            isCurrentPage: i == _currentPage,
          ),
          alignment: widget.alignment,
          scrollDirection: widget.scrollDirection,
          minSize: widget.expandToMaxSize ? _maxChildSize : 0,
          child: widget.children![i],
        ),
    ];
  }
}

class _SizeReportingChild extends StatelessWidget {
  final ValueChanged<Size> onSizeChange;
  final Widget child;
  final Alignment alignment;
  final Axis scrollDirection;

  /// Floor applied to the page's main-axis extent. In expandToMaxSize mode this
  /// is the tallest page, so every (shorter) page fills to the common height
  /// instead of shrink-wrapping and leaving a gap. 0 disables the floor.
  ///
  /// The page reports its *natural* size, laid out without the floor
  /// ([_MeasuredPage]). Measured with it, a page could never report less than
  /// the floor, so the floor could never come down again: a page view grown
  /// taller in landscape stayed that tall back in portrait.
  final double minSize;

  const _SizeReportingChild({
    required this.onSizeChange,
    required this.child,
    required this.alignment,
    required this.scrollDirection,
    required this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    return _MeasuredPage(
      onNaturalSize: onSizeChange,
      alignment: alignment,
      scrollDirection: scrollDirection,
      floor: minSize,
      child: child,
    );
  }
}

/// Lays a page out free along the main axis (as the `OverflowBox` it replaces
/// did), reports the size it comes out at, and only then applies [floor] — by
/// laying it out a second time when it is shorter. Fills the slot the page view
/// gives it, the page aligned in it by [alignment].
class _MeasuredPage extends SingleChildRenderObjectWidget {
  const _MeasuredPage({
    required this.onNaturalSize,
    required this.alignment,
    required this.scrollDirection,
    required this.floor,
    required super.child,
  });

  final ValueChanged<Size> onNaturalSize;
  final Alignment alignment;
  final Axis scrollDirection;
  final double floor;

  @override
  _RenderMeasuredPage createRenderObject(BuildContext context) => _RenderMeasuredPage(
        onNaturalSize: onNaturalSize,
        alignment: alignment,
        scrollDirection: scrollDirection,
        floor: floor,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderMeasuredPage renderObject) {
    renderObject
      ..onNaturalSize = onNaturalSize
      ..alignment = alignment
      ..scrollDirection = scrollDirection
      ..floor = floor;
  }
}

class _RenderMeasuredPage extends RenderShiftedBox {
  _RenderMeasuredPage({
    required this.onNaturalSize,
    required Alignment alignment,
    required Axis scrollDirection,
    required double floor,
  })  : _alignment = alignment,
        _scrollDirection = scrollDirection,
        _floor = floor,
        super(null);

  ValueChanged<Size> onNaturalSize;

  Alignment _alignment;
  set alignment(Alignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  Axis _scrollDirection;
  set scrollDirection(Axis value) {
    if (value == _scrollDirection) return;
    _scrollDirection = value;
    markNeedsLayout();
  }

  double _floor;
  set floor(double value) {
    if (value == _floor) return;
    _floor = value;
    markNeedsLayout();
  }

  Size? _reportedSize;

  /// Free along the main axis, as given across it — the `OverflowBox` this
  /// replaces: `maxHeight: infinity` for a horizontal page view, `minWidth: 0,
  /// maxWidth: infinity` for a vertical one.
  BoxConstraints get _freeConstraints => _scrollDirection == Axis.horizontal
      ? constraints.copyWith(minHeight: 0, maxHeight: double.infinity)
      : constraints.copyWith(minWidth: 0, maxWidth: double.infinity);

  @override
  void performLayout() {
    final child = this.child;
    size = constraints.biggest.isFinite ? constraints.biggest : constraints.smallest;
    if (child == null) return;

    final free = _freeConstraints;
    child.layout(free, parentUsesSize: true);
    final naturalSize = child.size;
    if (naturalSize != _reportedSize) {
      _reportedSize = naturalSize;
      // After the frame, as the size reporting this replaces did: the page
      // view rebuilds on a report, which it may not do mid-layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached && _reportedSize == naturalSize) onNaturalSize(naturalSize);
      });
    }

    // The floor only ever applied to a horizontal page view's height.
    if (_scrollDirection == Axis.horizontal && _floor > naturalSize.height) {
      child.layout(free.copyWith(minHeight: _floor), parentUsesSize: true);
    }

    final childParentData = child.parentData! as BoxParentData;
    childParentData.offset = _alignment.alongOffset(size - child.size as Offset);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.biggest.isFinite ? constraints.biggest : constraints.smallest;
}
