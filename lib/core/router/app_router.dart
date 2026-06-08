import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/call/call_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>   const HomeScreen(),
    ),
    GoRoute(
      path: '/call',
      builder: (context, state) {
        final roomId = state.uri.queryParameters['roomId'];
        final isJoining = state.uri.queryParameters['join'] == 'true';

        return CallScreen(
          roomId: roomId,
          isJoining: isJoining,
        );
      },
    ),
  ],
);