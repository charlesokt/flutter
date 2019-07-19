// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    LicenseRegistry.reset();
  });

  testWidgets('AboutListTile control test', (WidgetTester tester) async {
    const FlutterLogo logo = FlutterLogo();

    await tester.pumpWidget(
      MaterialApp(
        title: 'Pirate app',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
          ),
          drawer: Drawer(
            child: ListView(
              children: const <Widget>[
                AboutListTile(
                  applicationVersion: '0.1.2',
                  applicationIcon: logo,
                  applicationLegalese: 'I am the very model of a modern major general.',
                  aboutBoxChildren: <Widget>[
                    Text('About box'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('About Pirate app'), findsNothing);
    expect(find.text('0.1.2'), findsNothing);
    expect(find.byWidget(logo), findsNothing);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsNothing,
    );
    expect(find.text('About box'), findsNothing);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('About Pirate app'), findsOneWidget);
    expect(find.text('0.1.2'), findsNothing);
    expect(find.byWidget(logo), findsNothing);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsNothing,
    );
    expect(find.text('About box'), findsNothing);

    await tester.tap(find.text('About Pirate app'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('About Pirate app'), findsOneWidget);
    expect(find.text('0.1.2'), findsOneWidget);
    expect(find.byWidget(logo), findsOneWidget);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsOneWidget,
    );
    expect(find.text('About box'), findsOneWidget);

    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(<String>['Pirate package '], 'Pirate license'),
      ]);
    });

    await tester.tap(find.text('VIEW LICENSES'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Pirate app'), findsOneWidget);
    expect(find.text('0.1.2'), findsOneWidget);
    expect(find.byWidget(logo), findsOneWidget);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsOneWidget,
    );
    expect(find.text('Pirate license'), findsOneWidget);
  }, skip: isBrowser);

  testWidgets('About box logic defaults to executable name for app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        title: 'flutter_tester',
        home: Material(child: AboutListTile()),
      ),
    );
    expect(find.text('About flutter_tester'), findsOneWidget);
  });

  testWidgets('LicensePage control test', (WidgetTester tester) async {
    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(<String>['AAA'], 'BBB'),
      ]);
    });

    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(
          <String>['Another package'],
          'Another license',
        ),
      ]);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LicensePage(),
        ),
      ),
    );

    expect(find.text('AAA'), findsNothing);
    expect(find.text('BBB'), findsNothing);
    expect(find.text('Another package'), findsNothing);
    expect(find.text('Another license'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('BBB'), findsOneWidget);
    expect(find.text('Another package'), findsOneWidget);
    expect(find.text('Another license'), findsOneWidget);
  }, skip: isBrowser);

  testWidgets('LicensePage control test with all properties', (WidgetTester tester) async {
    const FlutterLogo logo = FlutterLogo();

    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(<String>['AAA'], 'BBB'),
      ]);
    });

    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(
          <String>['Another package'],
          'Another license',
        ),
      ]);
    });

    await tester.pumpWidget(
      const MaterialApp(
        title: 'Pirate app',
        home: Center(
          child: LicensePage(
            applicationName: 'LicensePage test app',
            applicationVersion: '0.1.2',
            applicationIcon: logo,
            applicationLegalese: 'I am the very model of a modern major general.',
          ),
        ),
      ),
    );

    expect(find.text('Pirate app'), findsNothing);
    expect(find.text('LicensePage test app'), findsOneWidget);
    expect(find.text('0.1.2'), findsOneWidget);
    expect(find.byWidget(logo), findsOneWidget);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsOneWidget,
    );
    expect(find.text('AAA'), findsNothing);
    expect(find.text('BBB'), findsNothing);
    expect(find.text('Another package'), findsNothing);
    expect(find.text('Another license'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Pirate app'), findsNothing);
    expect(find.text('LicensePage test app'), findsOneWidget);
    expect(find.text('0.1.2'), findsOneWidget);
    expect(find.byWidget(logo), findsOneWidget);
    expect(
      find.text('I am the very model of a modern major general.'),
      findsOneWidget,
    );
    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('BBB'), findsOneWidget);
    expect(find.text('Another package'), findsOneWidget);
    expect(find.text('Another license'), findsOneWidget);
  }, skip: isBrowser);

  testWidgets('LicensePage respects the notch', (WidgetTester tester) async {
    const double safeareaPadding = 27.0;

    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
        const LicenseEntryWithLineBreaks(<String>['ABC'], 'DEF'),
      ]);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            padding: EdgeInsets.all(safeareaPadding),
          ),
          child: LicensePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('DEF')), const Offset(8.0 + safeareaPadding, 287.0));
  }, skip: isBrowser);

  testWidgets('LicensePage returns early if unmounted', (WidgetTester tester) async {
    final Completer<LicenseEntry> licenseCompleter = Completer<LicenseEntry>();
    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromFuture(licenseCompleter.future);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LicensePage(),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: Placeholder(),
      ),
    );

    await tester.pumpAndSettle();
    final FakeLicenseEntry licenseEntry = FakeLicenseEntry();
    licenseCompleter.complete(licenseEntry);
    expect(licenseEntry.paragraphsCalled, false);
  }, skip: isBrowser);

  testWidgets('LicensePage returns late if unmounted', (WidgetTester tester) async {
    final Completer<LicenseEntry> licenseCompleter = Completer<LicenseEntry>();
    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromFuture(licenseCompleter.future);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LicensePage(),
      ),
    );
    await tester.pump();
    final FakeLicenseEntry licenseEntry = FakeLicenseEntry();
    licenseCompleter.complete(licenseEntry);

    await tester.pumpWidget(
      const MaterialApp(
        home: Placeholder(),
      ),
    );

    await tester.pumpAndSettle();
    expect(licenseEntry.paragraphsCalled, true);
  }, skip: isBrowser);

  testWidgets('LicensePage logic defaults to executable name for app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        title: 'flutter_tester',
        home: Material(child: LicensePage()),
      ),
    );
    expect(find.text('flutter_tester'), findsOneWidget);
  });
}

class FakeLicenseEntry extends LicenseEntry {
  FakeLicenseEntry();

  bool get paragraphsCalled => _paragraphsCalled;
  bool _paragraphsCalled = false;

  @override
  Iterable<String> packages = <String>[];

  @override
  Iterable<LicenseParagraph> get paragraphs {
    _paragraphsCalled = true;
    return <LicenseParagraph>[];
  }
}
