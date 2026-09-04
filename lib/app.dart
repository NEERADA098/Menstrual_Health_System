import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/cycle_tracking/presentation/bloc/cycle_bloc.dart';
import 'features/symptom_tracking/presentation/bloc/symptom_bloc.dart';

import 'core/sync/sync_manager.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<CycleBloc>(
          create: (_) => sl<CycleBloc>(),
        ),
        BlocProvider<SymptomBloc>(
          create: (_) => sl<SymptomBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(

        listener: (context, state) {

          if (state is AuthAuthenticated) {

            // Start listening for connectivity to trigger auto-sync

            sl<SyncManager>().initialize(state.user.uid);

          }

        },

        child: MaterialApp.router(
        title: 'CycleAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
