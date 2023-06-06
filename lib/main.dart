import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/router.dart';
import 'package:chat_app/screens/error_screen.dart';
import 'package:chat_app/screens/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/widgets/loader.dart';
import 'firebase_options.dart';
import 'common/utils/color.dart';
import 'package:chat_app/features/landing/screens/landing_sreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

// MyApp class extends ConsumerWidget, which is a widget that can read and
// listen to providers using the `ref` parameter.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      // Theme configuration for the app.
      theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(color: appBarColor)),

      // Route configuration for the app.
      onGenerateRoute: (settings) => generateRoute(settings),

      // The home widget that will be shown initially.
      // Uses ref.watch to listen to the `userDataAuthProvider` provider.
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              // If user is null, show the LandingScreen widget.
              if (user == null) {
                return const LandingScreen();
              }
              // Otherwise, show the MobileLayoutScreen widget.
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              // If there is an error with the provider, show the ErrorScreen widget.
              return ErrorScreen(
                error: err.toString(),
              );
            },
            loading: () => const Loader(),
          ),
    );
  }
}
