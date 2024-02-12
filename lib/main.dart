import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/pages/add_story.dart';
import 'package:story_app/pages/auth/login.dart';
import 'package:story_app/pages/auth/register.dart';
import 'package:story_app/pages/detail_story.dart';
import 'package:story_app/pages/home.dart';
import 'package:story_app/providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', ''),
        Locale('en', ''),
      ],
      debugShowCheckedModeBanner: false,
      // routerConfig: _router,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

final _key = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authRef = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _key,
    refreshListenable: authRef,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          if (authRef.isLoggedIn) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'register',
            name: "Register",
            builder: (BuildContext context, GoRouterState state) {
              return const RegisterPage();
            },
          ),
          GoRoute(
            path: 'login',
            name: "Login",
            builder: (BuildContext context, GoRouterState state) {
              return const LoginPage();
            },
          ),
          GoRoute(
            path: 'add-story',
            name: "AddStory",
            builder: (BuildContext context, GoRouterState state) {
              return const AddStoryPage();
            },
          ),
          GoRoute(
            path: 'detail/:id',
            name: "Detail",
            builder: (BuildContext context, GoRouterState state) {
              var id = state.pathParameters['id'];
              if (id == null) {
                return const SizedBox();
              } else {
                return DetailStoryPage(id: id);
              }
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authRef.isLoggedIn;

      if (isLoggedIn) {
        if (state.fullPath == "/login" || state.fullPath == "/register") {
          return '/home';
        }

        return null;
      } else {
        if (state.fullPath == "/login" ||
            state.fullPath == "/register" ||
            state.fullPath == "/") {
          return null;
        }
        return '/login';
      }
    },
  );
});
