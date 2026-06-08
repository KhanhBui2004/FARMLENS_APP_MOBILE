import 'package:farmlens_app/presentation/widgets/buttonCustom_widget.dart';
import 'package:farmlens_app/presentation/widgets/header.dart';
import 'package:farmlens_app/presentation/widgets/map_fullscreen_selector.dart';
import 'package:farmlens_app/presentation/widgets/map_panel.dart';
import 'package:farmlens_app/presentation/widgets/textInput_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  testWidgets('ButtonCustomWidget renders text and triggers callback', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ButtonCustomWidget(
            text: 'Submit',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('TextInputWidget shows label and validates input', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextInputWidget(
              hintText: 'Email',
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.pump();

    expect(controller.text, 'user@example.com');
    expect(formKey.currentState!.validate(), isTrue);

    controller.dispose();
  });

  testWidgets('HomeHeader opens menu and reports selected action', (
    tester,
  ) async {
    String? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeader(
            title: 'Dashboard',
            subtitle: 'Overview',
            onMenuSelected: (value) {
              selectedAction = value;
            },
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(selectedAction, 'Profile');
  });

  const initialCamera = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  testWidgets('MapPanel renders selected region and triggers buttons', (
    tester,
  ) async {
    var selected = false;
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapPanel(
            initialCamera: initialCamera,
            mapType: MapType.normal,
            onMapCreated: (_) {},
            onSelectRegion: () {
              selected = true;
            },
            onToggleMapType: () {
              toggled = true;
            },
            selectedRegionLabel: 'Selected area: Da Nang',
            selectionMarkers: const {},
          ),
        ),
      ),
    );

    expect(find.text('Selected area: Da Nang'), findsOneWidget);
    expect(find.byIcon(Icons.layers), findsOneWidget);
    expect(find.byIcon(Icons.crop_free), findsOneWidget);

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pump();

    expect(toggled, isTrue);

    await tester.tap(find.byIcon(Icons.crop_free));
    await tester.pump();

    expect(selected, isTrue);
  });

  testWidgets('MapFullscreenSelector disables confirm when no location selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapFullscreenSelector(
          initialCamera: initialCamera,
        ),
      ),
    );

    expect(find.text('Select area'), findsOneWidget);
    expect(find.text('Use location'), findsOneWidget);
    expect(find.text('Confirm location'), findsNothing);

    final TextButton useLocationButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Use location'),
    );

    expect(useLocationButton.onPressed, isNull);
  });

  testWidgets('MapFullscreenSelector shows initial selected location', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapFullscreenSelector(
          initialCamera: initialCamera,
          initialSelected: LatLng(16.0544, 108.2022),
        ),
      ),
    );

    expect(find.text('Select area'), findsOneWidget);
    expect(find.text('Use location'), findsOneWidget);
    expect(find.text('Confirm location'), findsOneWidget);

    final TextButton useLocationButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Use location'),
    );

    expect(useLocationButton.onPressed, isNotNull);
  });

  testWidgets('MapFullscreenSelector returns initial selected location', (
    tester,
  ) async {
    LatLng? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<LatLng>(
                    MaterialPageRoute(
                      builder: (_) => const MapFullscreenSelector(
                        initialCamera: initialCamera,
                        initialSelected: LatLng(16.0544, 108.2022),
                      ),
                    ),
                  );
                },
                child: const Text('Open selector'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open selector'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use location'));
    await tester.pumpAndSettle();

    expect(result, const LatLng(16.0544, 108.2022));
  });
}
