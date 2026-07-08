import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/page_view_height.dart';

void main() {
  testWidgets('''given expandToMaxSize is enabled
  and a wrong, tall size is reported while a page transition is in progress
  then that transient size is not committed
  and the settled height reflects the real page size''', (tester) async {
    // Regression: an off-screen page briefly laid out at the wrong width during
    // a swipe soft-wraps much taller than it really is. With expandToMaxSize
    // that transient height used to be captured as the never-shrinking maximum,
    // permanently inflating the page view.
    final secondPageHeight = ValueNotifier<double>(200);
    addTearDown(secondPageHeight.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandablePageView(
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
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.pageViewHeight, 200);

    // Begin swiping toward the second page, but hold mid-transition.
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(ExpandablePageView)));
    await gesture.moveBy(const Offset(-400, 0));
    await tester.pump();

    // A transient, wrong (tall) measurement arrives while scrolling.
    secondPageHeight.value = 1000;
    await tester.pump();
    expect(tester.pageViewHeight, 200,
        reason: 'a size reported mid-transition must not be committed');

    // The page settles at its real height.
    secondPageHeight.value = 300;
    await gesture.moveBy(const Offset(-400, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.pageViewHeight, 300,
        reason: 'after settling, height is the real page size, not the transient');
  });
}
