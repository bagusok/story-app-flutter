import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_app/common/flavor_config.dart';
import 'package:story_app/my_app.dart';

void main() {
  FlavorConfig(
    flavor: FlavorType.free,
  );
  runApp(const ProviderScope(child: MyApp()));
}
