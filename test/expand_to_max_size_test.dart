import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/page_view_height.dart';
import 'helpers/pump_app.dart';

const nextPageScrollOffset = Offset(-500, 0);

void main() {
  group('expandToMaxSize', () {
    testWidgets('''given expandToMaxSize is true
    and the current page is shorter than a previously shown page
    then the height stays at the tallest measured page''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          expandToMaxSize: true,
          children: [
            Container(color: Colors.red, height: 400),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(tester.pageViewHeight, 400);

      await tester.drag(find.byType(ExpandablePageView), nextPageScrollOffset);
      await tester.pumpAndSettle();

      // Stays at the max (400), does not shrink to the current page's 200.
      expect(tester.pageViewHeight, 400);
    });

    testWidgets('''given expandToMaxSize is true
    and a wrong, tall size is reported while a transition is in progress
    then that transient size is not committed
    and the settled height reflects the real page sizes''', (tester) async {
      // Regression: an off-screen page briefly laid out at the wrong width
      // during a swipe soft-wraps much taller than it really is; that transient
      // height must not be captured as the maximum.
      final secondPageHeight = ValueNotifier<double>(200);
      addTearDown(secondPageHeight.dispose);

      await tester.pumpApp(
        ExpandablePageView(
          expandToMaxSize: true,
          children: [
            Container(color: Colors.red, height: 200),
            ValueListenableBuilder<double>(
              valueListenable: secondPageHeight,
              builder: (_, height, __) =>
                  Container(color: Colors.blue, height: height),
            ),
          ],
        ),
      );
      expect(tester.pageViewHeight, 200);

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(ExpandablePageView)));
      await gesture.moveBy(const Offset(-400, 0));
      await tester.pump();

      secondPageHeight.value = 1000;
      await tester.pump();
      expect(tester.pageViewHeight, 200,
          reason: 'a size reported mid-transition must not be committed');

      secondPageHeight.value = 300;
      await gesture.moveBy(const Offset(-400, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 300,
          reason: 'after settling, height is max of real page sizes (200, 300)');
    });

    testWidgets('''given expandToMaxSize is true
    and the page view gets wider, then narrower again (a rotation)
    then the height follows the pages back down
    instead of staying at the tallest height it ever had''', (tester) async {
      // Regression: pages were measured with the fill floor applied, so none
      // could report less than the floor, and the floor never came down — a
      // page view grown taller in landscape kept that height in portrait.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      // In a scroll view, as on a page: in landscape the screen is shorter than
      // the page view.
      await tester.pumpApp(
        SingleChildScrollView(
          child: ExpandablePageView(
            expandToMaxSize: true,
            children: const [
              AspectRatio(aspectRatio: 4 / 3, child: ColoredBox(color: Colors.red)),
              AspectRatio(aspectRatio: 2, child: ColoredBox(color: Colors.blue)),
            ],
          ),
        ),
      );
      expect(tester.pageViewHeight, 300);

      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 600);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 300, reason: 'back at the narrow width: the narrow height');
    });

    testWidgets('''given expandToMaxSize is true
    and a page further back was last laid out at the wide width
    then back at the narrow width that old measurement does not count''', (tester) async {
      // Regression: the current width was taken from the stored reports in
      // page order, so a page last measured before the rotation — never laid
      // out again since — set the width back to the old one, and the old
      // heights counted again.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final controller = PageController(viewportFraction: 0.9);
      addTearDown(controller.dispose);
      await tester.pumpApp(
        SingleChildScrollView(
          child: ExpandablePageView(
            controller: controller,
            expandToMaxSize: true,
            children: const [
              AspectRatio(aspectRatio: 4 / 3, child: ColoredBox(color: Colors.red)),
              AspectRatio(aspectRatio: 4 / 3, child: ColoredBox(color: Colors.green)),
              AspectRatio(aspectRatio: 4 / 3, child: ColoredBox(color: Colors.blue)),
              AspectRatio(aspectRatio: 4 / 3, child: ColoredBox(color: Colors.yellow)),
            ],
          ),
        ),
      );
      final portraitHeight = tester.pageViewHeight;

      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle();
      final landscapeHeight = tester.pageViewHeight;
      expect(landscapeHeight, greaterThan(portraitHeight));

      // Visit the last page in landscape, so it is measured at the wide width,
      // and come back: it is not laid out again from here.
      controller.jumpToPage(3);
      await tester.pumpAndSettle();
      controller.jumpToPage(0);
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, portraitHeight);
    });

    testWidgets('''given expandToMaxSize is true
    and a page shorter than the tallest one
    then it still fills the common height''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          expandToMaxSize: true,
          children: [
            Container(color: Colors.red, height: 400),
            const ColoredBox(key: Key('short'), color: Colors.blue, child: SizedBox(height: 100)),
          ],
        ),
      );
      await tester.drag(find.byType(ExpandablePageView), nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byKey(const Key('short'))).height, 400);
    });
  });
}
