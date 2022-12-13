import 'package:bingo/providers/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

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
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
