import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_project/core/di/injector.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_cubit.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_state.dart';
import 'package:flutter_complete_project/src/features/home/presentation/widgets/neumorphic_ripple_button.dart';
import 'package:flutter_complete_project/src/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<ShazamCubit>(
        create: (_) => getIt<ShazamCubit>(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF008EFF), Color(0xFF006AFF), Color(0xFF004EFF)],
            ),
          ),
          child: BlocConsumer<ShazamCubit, ShazamState>(
            listener: (context, state) {
              switch (state) {
                case final ShazamSuccess success:
                  _goToDetails(context, success.result);
                case ShazamError():
                  _showErrorDialog(context);
                default:
                  break;
              }
            },
            builder: (context, state) {
              final isListening = state is ShazamListening;

              return Center(
                child: NeumorphicRippleButton(
                  heroTag: AppHeroes.listenerOrb,
                  rippling: isListening,
                  onTap: () => context.read<ShazamCubit>().startListening(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _goToDetails(BuildContext context, ShazamResult result) {
    context.push(AppRoutes.songDetails, extra: result).then((_) {
      if (context.mounted) {
        context.read<ShazamCubit>().resetListening();
      }
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFF0B3B7A),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: 48,
        ),
        title: const Text(
          'Could not identify the song',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          (context.read<ShazamCubit>().state as ShazamError).message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<ShazamCubit>().resetListening();
      }
    });
  }
}
