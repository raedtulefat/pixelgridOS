69 results - 26 files

pixelgridOS • pubspec.yaml:
  1: name: game_shell
  2  description: A reusable pixelgrid built with Flutter and Flame.

pixelgridOS • README.md:
  1: # game_shell
  2  

pixelgridOS • android/app/build.gradle:
  15          // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
  16:         applicationId "com.example.game_shell"
  17          minSdkVersion 16

pixelgridOS • android/app/build.gradle.kts:
   8  android {
   9:     namespace = "com.example.game_shell"
  10      compileSdk = flutter.compileSdkVersion

  23          // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
  24:         applicationId = "com.example.game_shell"
  25          // You can update the following values to match your application needs.

pixelgridOS • android/app/src/debug/AndroidManifest.xml:
  1  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
  2:     package="com.example.game_shell">
  3      <!-- Flutter needs it to communicate with the running application

pixelgridOS • android/app/src/main/AndroidManifest.xml:
  1  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
  2:     package="com.example.game_shell">
  3     <application

pixelgridOS • android/app/src/main/kotlin/com/example/game_shell/MainActivity.kt:
  1: package com.example.game_shell
  2  

pixelgridOS • android/app/src/profile/AndroidManifest.xml:
  1  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
  2:     package="com.example.game_shell">
  3      <!-- Flutter needs it to communicate with the running application

pixelgridOS • assets/version.json:
  1: {"app_name":"game_shell","version":"0.0.36","build_number":"1","package_name":"game_shell"}

pixelgridOS • ios/Runner.xcodeproj/project.pbxproj:
  369  				);
  370: 				PRODUCT_BUNDLE_IDENTIFIER = com.raedtulefat.game_shell;
  371  				PRODUCT_NAME = "$(TARGET_NAME)";

  497  				);
  498: 				PRODUCT_BUNDLE_IDENTIFIER = com.example.game_shell;
  499  				PRODUCT_NAME = "$(TARGET_NAME)";

  520  				);
  521: 				PRODUCT_BUNDLE_IDENTIFIER = com.example.game_shell;
  522  				PRODUCT_NAME = "$(TARGET_NAME)";

pixelgridOS • lib/main.dart:
  3  import 'package:flame/game.dart';
  4: import 'package:game_shell/os.dart';
  5: import 'package:game_shell/menus/menu_overlay.dart';
  6  

pixelgridOS • lib/os.dart:
  1: import 'package:game_shell/os/internal/shell_os_impl.dart';
  2  

pixelgridOS • lib/menus/menu_overlay.dart:
   5      show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
   6: import 'package:game_shell/os.dart';
   7: import 'package:game_shell/fake_pixels/logo_asset_catalog.dart';
   8: import 'package:game_shell/menus/menu_style.dart';
   9: import 'package:game_shell/menus/settings_menu.dart';
  10: import 'package:game_shell/settings/settings_applier.dart';
  11: import 'package:game_shell/settings/settings_controller.dart';
  12: import 'package:game_shell/settings/settings_keys.dart';
  13: import 'package:game_shell/settings/settings_storage.dart';
  14: import 'package:game_shell/ui/menu_column.dart';
  15: import 'package:game_shell/ui/modal.dart';
  16: import 'package:game_shell/ui/pixel/pixel_border_button.dart';
  17  

pixelgridOS • lib/menus/settings_menu.dart:
  2  
  3: import "package:game_shell/os.dart";
  4: import "package:game_shell/menus/menu_overlay_types.dart";
  5: import "package:game_shell/menus/menu_style.dart";
  6: import "package:game_shell/settings/settings_controller.dart";
  7: import "package:game_shell/ui/menu_column.dart";
  8: import "package:game_shell/ui/modal.dart";
  9: import "package:game_shell/ui/pixel/pixel_border_button.dart";
  10  

pixelgridOS • lib/os/internal/shell_os_impl.dart:
   7      show PointerCancelEvent, PointerDownEvent, PointerMoveEvent, PointerUpEvent;
   8: import 'package:game_shell/fake_pixels/fake_pixels_config.dart';
   9: import 'package:game_shell/fake_pixels/fake_pixels_engine.dart';
  10: import 'package:game_shell/os/debug/debug_ui_controller.dart';
  11: import 'package:game_shell/os/os_mode.dart';
  12  

pixelgridOS • lib/settings/settings_applier.dart:
  1: import 'package:game_shell/os.dart';
  2: import 'package:game_shell/settings/settings_controller.dart';
  3  

pixelgridOS • lib/settings/settings_controller.dart:
  1: import 'package:game_shell/settings/settings_storage.dart';
  2  

pixelgridOS • lib/ui/modal.dart:
  1  import 'package:flutter/material.dart';
  2: import 'package:game_shell/ui/pixel/pixel_border_painter.dart';
  3  

pixelgridOS • linux/CMakeLists.txt:
   6  # the on-disk name of your application.
   7: set(BINARY_NAME "game_shell")
   8  # The unique GTK application identifier for this application. See:
   9  # https://wiki.gnome.org/HowDoI/ChooseApplicationID
  10: set(APPLICATION_ID "com.example.game_shell")
  11  

pixelgridOS • linux/runner/my_application.cc:
  47      gtk_widget_show(GTK_WIDGET(header_bar));
  48:     gtk_header_bar_set_title(header_bar, "game_shell");
  49      gtk_header_bar_set_show_close_button(header_bar, TRUE);

  51    } else {
  52:     gtk_window_set_title(window, "game_shell");
  53    }

pixelgridOS • macos/Runner/Configs/AppInfo.xcconfig:
  7  // The application's name. By default this is also the title of the Flutter window.
  8: PRODUCT_NAME = game_shell
  9  

pixelgridOS • macos/Runner.xcodeproj/project.pbxproj:
   66  		335BBD1A22A9A15E00E9071D /* GeneratedPluginRegistrant.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = GeneratedPluginRegistrant.swift; sourceTree = "<group>"; };
   67: 		33CC10ED2044A3C60003C045 /* game_shell.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "game_shell.app"; sourceTree = BUILT_PRODUCTS_DIR; };
   68  		33CC10F02044A3C60003C045 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };

  133  			children = (
  134: 				33CC10ED2044A3C60003C045 /* game_shell.app */,
  135  				331C80D5294CF71000263BE5 /* RunnerTests.xctest */,

  219  			productName = Runner;
  220: 			productReference = 33CC10ED2044A3C60003C045 /* game_shell.app */;
  221  			productType = "com.apple.product-type.application";

  390  				SWIFT_VERSION = 5.0;
  391: 				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/game_shell.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/game_shell";
  392  			};

  404  				SWIFT_VERSION = 5.0;
  405: 				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/game_shell.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/game_shell";
  406  			};

  418  				SWIFT_VERSION = 5.0;
  419: 				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/game_shell.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/game_shell";
  420  			};

pixelgridOS • macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme:
  17                 BlueprintIdentifier = "33CC10EC2044A3C60003C045"
  18:                BuildableName = "game_shell.app"
  19                 BlueprintName = "Runner"

  33              BlueprintIdentifier = "33CC10EC2044A3C60003C045"
  34:             BuildableName = "game_shell.app"
  35              BlueprintName = "Runner"

  68              BlueprintIdentifier = "33CC10EC2044A3C60003C045"
  69:             BuildableName = "game_shell.app"
  70              BlueprintName = "Runner"

  85              BlueprintIdentifier = "33CC10EC2044A3C60003C045"
  86:             BuildableName = "game_shell.app"
  87              BlueprintName = "Runner"

pixelgridOS • windows/CMakeLists.txt:
  2  cmake_minimum_required(VERSION 3.14)
  3: project(game_shell LANGUAGES CXX)
  4  

  6  # the on-disk name of your application.
  7: set(BINARY_NAME "game_shell")
  8  

pixelgridOS • windows/runner/main.cpp:
  29    Win32Window::Size size(1280, 720);
  30:   if (!window.Create(L"game_shell", origin, size)) {
  31      return EXIT_FAILURE;

pixelgridOS • windows/runner/Runner.rc:
  92              VALUE "CompanyName", "com.example" "\0"
  93:             VALUE "FileDescription", "game_shell" "\0"
  94              VALUE "FileVersion", VERSION_AS_STRING "\0"
  95:             VALUE "InternalName", "game_shell" "\0"
  96              VALUE "LegalCopyright", "Copyright (C) 2026 com.example. All rights reserved." "\0"
  97:             VALUE "OriginalFilename", "game_shell.exe" "\0"
  98:             VALUE "ProductName", "game_shell" "\0"
  99              VALUE "ProductVersion", VERSION_AS_STRING "\0"
