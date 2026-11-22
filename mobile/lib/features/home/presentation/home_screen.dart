import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页 / 今日任务占位页。
///
/// TODO(M1): 接入今日任务、复习进度环、卡片集列表。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('CardSharp')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.style_outlined, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('卡锐思', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '可拓展的 AI 卡片助手',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              const Text('M0 脚手架已就绪'),
            ],
          ),
        ),
      ),
    );
  }
}
