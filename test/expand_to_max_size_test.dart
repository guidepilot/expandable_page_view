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
  });
}
