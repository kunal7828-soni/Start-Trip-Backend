import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_buddy/main.dart';

void main() {
  testWidgets('TripBuddyApp compiles and mounts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TripBuddyApp(),
      ),
    );

    // Verify that our app builds successfully and mounts elements.
    expect(find.byType(TripBuddyApp), findsOneWidget);
  });
}
