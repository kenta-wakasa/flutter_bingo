import 'package:bingo/constants/constants.dart';
import 'package:bingo/pages/new_user_page.dart';
import 'package:bingo/providers/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'pages/lottery_page.dart';
import 'pages/room_page.dart';
import 'pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: ((context, state) {
        return const NoTransitionPage(
          child: StartPage(),
        );
      }),
    ),
    GoRoute(
      path: '/room/:rid',
      pageBuilder: ((context, state) {
        return NoTransitionPage(
          child: ProviderScope(
            overrides: [
              roomIdProvider.overrideWithValue(state.params['rid']!),
            ],
            child: RoomPage(
              roomId: state.params['rid']!,
            ),
          ),
        );
      }),
      routes: [
        GoRoute(
          path: 'new',
          pageBuilder: ((context, state) {
            return NoTransitionPage(
              child: NewUserPage(
                roomId: state.params['rid']!,
              ),
            );
          }),
        ),
        GoRoute(
          path: 'user/:uid',
          pageBuilder: ((context, state) {
            return NoTransitionPage(
              child: ProviderScope(
                overrides: [
                  roomIdProvider.overrideWithValue(state.params['rid']!),
                  userIdProvider.overrideWithValue(state.params['uid']!),
                ],
                child: LotteryPage(
                  roomId: state.params['rid']!,
                  userId: state.params['uid']!,
                ),
              ),
            );
          }),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
          primaryColor: Constants.primaryColor,
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Constants.secondlyColor,
                onPrimary: Colors.black87,
                secondary: Constants.secondlyColor,
              ),
          hintColor: Colors.white70,
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            backgroundColor: Constants.primaryColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: GoogleFonts.rocknRollOneTextTheme()
              .copyWith(
                displayLarge:
                    GoogleFonts.rocknRollOneTextTheme().displayLarge?.copyWith(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
              )
              .apply(
                displayColor: Constants.secondlyColor,
                bodyColor: Colors.white,
              ),
          scaffoldBackgroundColor: Constants.primaryColor),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
