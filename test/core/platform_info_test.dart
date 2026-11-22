import 'package:bars/core/platform/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PlatformInfo derives booleans from the platform value', () {
    expect(const _FakePlatformInfo(AppPlatform.android).isAndroid, isTrue);
    expect(const _FakePlatformInfo(AppPlatform.android).isLinux, isFalse);
    expect(const _FakePlatformInfo(AppPlatform.linux).isAndroid, isFalse);
    expect(const _FakePlatformInfo(AppPlatform.linux).isLinux, isTrue);
    expect(const _FakePlatformInfo(AppPlatform.other).isAndroid, isFalse);
    expect(const _FakePlatformInfo(AppPlatform.other).isLinux, isFalse);
  });
}

final class _FakePlatformInfo extends PlatformInfo {
  const new(this.platform);

  @override
  final AppPlatform platform;
}
