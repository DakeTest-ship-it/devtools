// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:devtools_app/devtools_app.dart';
import 'package:devtools_app/src/screens/memory/panes/diff/controller/diff_pane_controller.dart';
import 'package:devtools_app/src/screens/memory/panes/diff/diff_pane.dart';
import 'package:devtools_app/src/screens/memory/shared/heap/class_filter.dart';
import 'package:devtools_app/src/screens/memory/shared/heap/model.dart';
import 'package:devtools_app/src/shared/memory/adapted_heap_data.dart';
import 'package:devtools_test/devtools_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/stager.dart';

import '../../../test_infra/test_data/memory/heap/heap_data.dart';

/// To run:
/// flutter run -t test/test_infra/scenes/memory/diff_snapshot.stager_app.dart -d macos
class DiffSnapshotScene extends Scene {
  late DiffPaneController diffController;
  late FakeServiceManager fakeServiceManager;

  @override
  Widget build(BuildContext context) {
    return wrap(
      SnapshotInstanceItemPane(controller: diffController),
    );
  }

  @override
  Future<void> setUp() async {
    setGlobal(OfflineModeController, OfflineModeController());
    setGlobal(IdeTheme, IdeTheme());
    setGlobal(NotificationService, NotificationService());

    fakeServiceManager =
        FakeServiceManager(service: FakeServiceManager.createFakeService());
    mockConnectedApp(
      fakeServiceManager.connectedApp!,
      isFlutterApp: true,
      isProfileBuild: true,
      isWebApp: false,
    );
    setGlobal(ServiceConnectionManager, fakeServiceManager);

    diffController = DiffPaneController(_TestSnapshotTaker());
    setClassFilterToShowAll();

    await diffController.takeSnapshot();
    await diffController.takeSnapshot();
  }

  @override
  String get title => '$DiffSnapshotScene';

  void setClassFilterToShowAll() {
    diffController.derived.applyFilter(
      ClassFilter(filterType: ClassFilterType.showAll, except: '', only: ''),
    );
  }

  void tearDown() {}
}

/// Provides test snapshots.
class _TestSnapshotTaker implements SnapshotTaker {
  int _nextIndex = 0;

  @override
  Future<AdaptedHeapData?> take() async {
    // This delay is needed for UI to start showing the progress indicator.
    await Future.delayed(const Duration(milliseconds: 100));
    final result = await goldenHeapTests[_nextIndex].loadHeap();

    _nextIndex = (_nextIndex + 1) % goldenHeapTests.length;

    return result;
  }
}
