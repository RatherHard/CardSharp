import 'dart:io';

import 'package:cardsharp/features/decks/data/file_deck_cover_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `FileDeckCoverService` 的落盘行为：
/// 选图 → 复制进私有目录并记路径；换图 → 新路径 + 删旧文件；移除 → 删文件清记录；
/// 文件被外部删掉 → 读到 null 并自愈。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory supportDir;
  late Directory sourceDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    supportDir = await Directory.systemTemp.createTemp('cover_support_');
    sourceDir = await Directory.systemTemp.createTemp('cover_source_');
  });

  tearDown(() async {
    for (final Directory dir in <Directory>[supportDir, sourceDir]) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  });

  Future<File> writeSource(String name) async {
    final File file = File('${sourceDir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(<int>[137, 80, 78, 71]);
    return file;
  }

  FileDeckCoverService buildService({String? Function()? pickPath}) {
    return FileDeckCoverService(
      directoryProvider: () async => supportDir,
      pickImagePath: () async => pickPath?.call(),
    );
  }

  test('没有封面时返回 null', () async {
    final FileDeckCoverService service = buildService();
    expect(await service.readCoverPath('1'), isNull);
  });

  test('选图后复制到私有目录，并记录路径', () async {
    final File source = await writeSource('cover.png');
    final FileDeckCoverService service = buildService(pickPath: () => source.path);

    final String? saved = await service.pickAndSaveCover('1');

    expect(saved, isNotNull);
    // 文件名是 `<deckId>-<时间戳>.png`，带时间戳是为了让换图后路径必变。
    expect(saved, contains('${Platform.pathSeparator}1-'));
    expect(saved, endsWith('.png'));
    expect(await File(saved!).exists(), isTrue);
    expect(await service.readCoverPath('1'), saved);
    // 原文件不受影响（复制而非移动）。
    expect(await source.exists(), isTrue);
  });

  test('用户取消时不改动已有封面', () async {
    final File source = await writeSource('first.png');
    final FileDeckCoverService first = buildService(pickPath: () => source.path);
    final String? saved = await first.pickAndSaveCover('1');

    final FileDeckCoverService cancelled = buildService(pickPath: () => null);
    expect(await cancelled.pickAndSaveCover('1'), isNull);
    expect(await cancelled.readCoverPath('1'), saved);
  });

  test('换封面会删除旧文件，目录里只留一张', () async {
    final File png = await writeSource('old.png');
    final File jpg = await writeSource('new.jpg');
    final FileDeckCoverService service = buildService(pickPath: () => png.path);
    final String? oldPath = await service.pickAndSaveCover('1');

    final FileDeckCoverService replaced = buildService(pickPath: () => jpg.path);
    final String? newPath = await replaced.pickAndSaveCover('1');

    expect(newPath, isNotNull);
    expect(newPath, isNot(oldPath));
    expect(await File(oldPath!).exists(), isFalse);
    final Directory coverDir = Directory('${supportDir.path}${Platform.pathSeparator}deck_covers');
    expect(await coverDir.list().length, 1);
  });

  test('同一卡片集换成相同扩展名的图，路径也会变', () async {
    // 真机踩坑：沿用 `<deckId>.png` 覆盖写时，Image.file 的缓存键（路径）没变，
    // 界面会一直显示旧封面，必须重启 App 才更新。
    final File first = await writeSource('first.png');
    final File second = await writeSource('second.png');
    final FileDeckCoverService service = buildService(pickPath: () => first.path);
    final String? oldPath = await service.pickAndSaveCover('1');

    final FileDeckCoverService replaced = buildService(pickPath: () => second.path);
    final String? newPath = await replaced.pickAndSaveCover('1');

    expect(newPath, isNotNull);
    expect(newPath, isNot(oldPath));
    expect(await File(oldPath!).exists(), isFalse);
  });

  test('移除封面会删文件并清记录', () async {
    final File source = await writeSource('cover.png');
    final FileDeckCoverService service = buildService(pickPath: () => source.path);
    final String? saved = await service.pickAndSaveCover('1');

    await service.removeCover('1');

    expect(await File(saved!).exists(), isFalse);
    expect(await service.readCoverPath('1'), isNull);
  });

  test('记录还在但文件被删掉时读到 null 并自愈', () async {
    final File source = await writeSource('cover.png');
    final FileDeckCoverService service = buildService(pickPath: () => source.path);
    final String? saved = await service.pickAndSaveCover('1');
    await File(saved!).delete();

    expect(await service.readCoverPath('1'), isNull);
    // 自愈：记录已清，再读依旧 null。
    expect(await service.readCoverPath('1'), isNull);
  });

  test('两个卡片集各自独立的封面', () async {
    final File a = await writeSource('a.png');
    final File b = await writeSource('b.png');
    final FileDeckCoverService serviceA = buildService(pickPath: () => a.path);
    final FileDeckCoverService serviceB = buildService(pickPath: () => b.path);

    final String? pathA = await serviceA.pickAndSaveCover('1');
    final String? pathB = await serviceB.pickAndSaveCover('2');

    expect(pathA, isNot(pathB));
    expect(await serviceA.readCoverPath('1'), pathA);
    expect(await serviceB.readCoverPath('2'), pathB);
  });
}
