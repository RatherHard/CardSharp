import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_strings.dart';
import '../../decks/domain/deck_repository.dart';

/// 恢复单张卡片时用户选的目标。
class RestoreDestination {
  const RestoreDestination({required this.createNew, this.newTitle = ''});

  /// true = 新建一个卡片集（[newTitle] 是它的名字）；false = 原卡片集。
  final bool createNew;
  final String newTitle;
}

/// 恢复整个卡片集前的确认。
Future<bool> confirmRestoreDeck(BuildContext context, String title) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text(AppStrings.trashRestoreDeckTitle),
      content: Text(AppStrings.trashRestoreDeckConfirm(title)),
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('trash_restore_deck_cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('trash_restore_deck_confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.trashRestore),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// 「恢复到哪」：原卡片集，或新建一个卡片集（标题默认「<原集名>恢复」，可改）。
///
/// [originalHint] 不为空时显示在原卡片集这一项下面，用来提醒副作用
/// （例如原卡片集还在回收站，会连带恢复）。
Future<RestoreDestination?> pickRestoreDestination(
  BuildContext context, {
  required String sourceDeckTitle,
  required bool originalAvailable,
  String? originalHint,
}) {
  return showModalBottomSheet<RestoreDestination>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => _RestoreCardSheet(
      sourceDeckTitle: sourceDeckTitle,
      originalAvailable: originalAvailable,
      originalHint: originalHint,
    ),
  );
}

class _RestoreCardSheet extends StatefulWidget {
  const _RestoreCardSheet({
    required this.sourceDeckTitle,
    required this.originalAvailable,
    this.originalHint,
  });

  final String sourceDeckTitle;
  final bool originalAvailable;
  final String? originalHint;

  @override
  State<_RestoreCardSheet> createState() => _RestoreCardSheetState();
}

class _RestoreCardSheetState extends State<_RestoreCardSheet> {
  bool _createNew = false;
  late final TextEditingController _titleController = TextEditingController(
    text: '${widget.sourceDeckTitle}恢复',
  );

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(AppStrings.trashRestoreCardTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            // RadioGroup 统一管选中值：RadioListTile 自己不再带 groupValue/onChanged
            //（Flutter 3.32 起那两个参数废弃，analyze --fatal-infos 会报 info）。
            RadioGroup<bool>(
              groupValue: _createNew,
              onChanged: (bool? value) => setState(() => _createNew = value ?? _createNew),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<bool>(
                    key: const ValueKey<String>('trash_restore_to_original'),
                    value: false,
                    enabled: widget.originalAvailable,
                    title: const Text(AppStrings.trashRestoreToOriginal),
                    subtitle: widget.originalHint == null ? null : Text(widget.originalHint!),
                  ),
                  const RadioListTile<bool>(
                    key: ValueKey<String>('trash_restore_to_new'),
                    value: true,
                    title: Text(AppStrings.trashRestoreToNew),
                  ),
                ],
              ),
            ),
            if (_createNew) ...<Widget>[
              const SizedBox(height: 4),
              TextField(
                key: const ValueKey<String>('trash_restore_new_title'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.trashRestoreNewTitleLabel,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey<String>('trash_restore_card_cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.actionCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey<String>('trash_restore_card_confirm'),
                    onPressed: () {
                      final String title = _titleController.text.trim();
                      if (_createNew && title.isEmpty) {
                        return;
                      }
                      Navigator.of(context)
                          .pop(RestoreDestination(createNew: _createNew, newTitle: title));
                    },
                    child: const Text(AppStrings.trashRestore),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showRestoredToast(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: ValueKey<String>('trash_restored_toast'),
      content: Text(AppStrings.trashRestoreDone),
    ),
  );
}

void showRestoreFailedToast(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: ValueKey<String>('trash_restore_failed_toast'),
      content: Text(AppStrings.trashRestoreFailed),
    ),
  );
}

/// 恢复撞名：书架里已有同名卡片集，恢复被拒绝（不产生重名）。
void showRestoreDuplicateToast(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: ValueKey<String>('trash_restore_duplicate_toast'),
      content: Text(AppStrings.deckDuplicateTitle),
    ),
  );
}

/// 恢复失败的统一出口：重名单独提示，其余走通用失败提示。
///
/// 回收站三个恢复入口（恢复整集、把单卡恢复到新集、回收站详情页）都调这里，
/// 避免「哪种失败该说哪句话」在三处各写一遍。
void showRestoreFailureToast(BuildContext context, Object error) {
  if (error is DeckException && error.failure == DeckFailure.duplicateTitle) {
    showRestoreDuplicateToast(context);
    return;
  }
  showRestoreFailedToast(context);
}
