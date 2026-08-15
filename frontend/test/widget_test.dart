import 'package:flutter_test/flutter_test.dart';
import 'package:campus_lost_found/ui/app.dart';

void main() {
  testWidgets('The app shows the home screen with key actions', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Campus Lost & Found'), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Browse Items'), findsOneWidget);
    expect(find.text('Post an Item'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
