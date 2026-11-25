import 'dart:io';
import 'dart:typed_data';

import 'package:alloy/core/platform/cover_files.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory folder;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('alloy-covers');
  });

  tearDown(() async {
    await folder.delete(recursive: true);
  });

  String file(String name) {
    final path = '${folder.path}/$name';
    File(path).writeAsBytesSync(name.codeUnits);
    return path;
  }

  test('prefers cover over folder and front', () {
    file('front.png');
    file('folder.png');
    file('cover.jpg');

    expect(folderCoverBytes('${folder.path}/song.mp3'), 'cover.jpg'.codeUnits);
  });

  test('accepts upper and lower case names', () {
    file('Folder.JPG');

    expect(folderCoverBytes('${folder.path}/song.mp3'), 'Folder.JPG'.codeUnits);
  });

  test('ignores unrelated images', () {
    file('artwork.png');
    file('liner-notes.jpg');

    expect(folderCoverBytes('${folder.path}/song.mp3'), isNull);
  });

  test('caches folder bytes for one scan batch', () {
    final path = file('cover.png');
    final cache = <String, Uint8List?>{};

    expect(
      folderCoverBytes('${folder.path}/song.mp3', cache: cache),
      isNotNull,
    );
    File(path).writeAsBytesSync([9, 9, 9]);

    expect(folderCoverBytes('${folder.path}/other.mp3', cache: cache), [
      99,
      111,
      118,
      101,
      114,
      46,
      112,
      110,
      103,
    ]);
  });

  test('falls back to the folder cover when tags are unreadable', () {
    file('cover.png');

    expect(readLocalCoverBytes('${folder.path}/broken.mp3'), isNotNull);
  });
}
