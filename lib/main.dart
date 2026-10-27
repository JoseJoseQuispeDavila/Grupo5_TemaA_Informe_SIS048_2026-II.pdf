import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProviderScope(child: BiblioTrackApp()));
}

class BiblioTrackApp extends StatelessWidget {
  const BiblioTrackApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BiblioTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C4A7C)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
