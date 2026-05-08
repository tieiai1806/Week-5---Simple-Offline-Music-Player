import 'package:flutter_test/flutter_test.dart';
import 'package:simple_music_player/main.dart';

void main() {
  testWidgets('Music player app load test', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicApp());

    expect(find.byType(MusicApp), findsOneWidget);
  });
}