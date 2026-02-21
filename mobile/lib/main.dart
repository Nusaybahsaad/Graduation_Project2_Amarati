import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/community/presentation/bloc/community_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AmaratiApp());
}

class AmaratiApp extends StatelessWidget {
  const AmaratiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>()..add(LoadNotifications()),
        ),
        BlocProvider<BillingBloc>(create: (_) => di.sl<BillingBloc>()),
        BlocProvider<CommunityBloc>(create: (_) => di.sl<CommunityBloc>()),
      ],
      child: MaterialApp(
        title: 'Amarati',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', '')],
        locale: const Locale('ar', ''),
        home: const SplashPage(),
      ),
    );
  }
}
