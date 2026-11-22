import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guards the dependency rules in AGENTS.md that the analyzer cannot express.
///
/// The project cannot use `import_lint` (its current release requires an
/// analyzer version that conflicts with drift_dev/riverpod_generator), so the
/// same boundaries are checked here and fail `flutter test` on violation.
void main() {
  final files = _readSources();

  test('presentation never imports data', () {
    _expectNoViolation(
      files,
      appliesTo: (uri) => _isLayer(uri, 'presentation'),
      forbidden: (uri) => _isLayer(uri, 'data'),
      reason: 'presentation talks to domain; data is injected by the app',
    );
  });

  test('domain is pure Dart', () {
    _expectNoViolation(
      files,
      appliesTo: (uri) => _isLayer(uri, 'domain'),
      forbidden: (uri) =>
          uri.startsWith('package:flutter/') ||
          uri.startsWith('package:drift/') ||
          uri.startsWith('package:drift_flutter/') ||
          _isLayer(uri, 'data') ||
          _platformLibraries.contains(uri),
      reason: 'domain must not depend on Flutter, Drift or platform libraries',
    );
  });

  test('a feature only imports another feature through its domain', () {
    final violations = <String>[];
    for (final file in files) {
      final feature = _featureOf(file.uri);
      if (feature == null) continue;
      for (final import in file.imports) {
        final importedFeature = _featureOf(import);
        if (importedFeature == null || importedFeature == feature) continue;
        if (_layerOf(import) != 'domain') {
          violations.add('${file.uri} -> $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: "features may only import other features' domain layer",
    );
  });

  test('core and shared stay feature-agnostic', () {
    _expectNoViolation(
      files,
      appliesTo: (uri) =>
          uri.startsWith('package:bars/core/') ||
          uri.startsWith('package:bars/shared/'),
      forbidden: (uri) => uri.startsWith('package:bars/features/'),
      reason: 'core and shared must not know about features',
    );
  });

  test('dart:io is only used behind core/platform and bootstrap', () {
    _expectNoViolation(
      files,
      appliesTo: (uri) =>
          !uri.startsWith('package:bars/core/platform/') &&
          uri != 'package:bars/app/bootstrap.dart',
      forbidden: (uri) => uri == 'dart:io',
      reason: 'platform differences belong behind core/platform interfaces',
    );
  });
}

const _packageName = 'bars';
const _sourceRoot = 'lib';

const _generatedSuffixes = ['.g.dart', '.freezed.dart', '.gr.dart'];

const _platformLibraries = {
  'dart:ffi',
  'dart:html',
  'dart:io',
  'dart:js',
  'dart:js_interop',
  'dart:ui',
};

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

final _feature = RegExp('^package:$_packageName/features/([^/]+)/');
final _layer = RegExp('^package:$_packageName/features/[^/]+/([^/]+)/');

final class _SourceFile {
  const new(this.uri, this.imports);

  final String uri;
  final List<String> imports;
}

List<_SourceFile> _readSources() {
  final sources = <_SourceFile>[];
  for (final entity in Directory(_sourceRoot).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (_generatedSuffixes.any(entity.path.endsWith)) continue;
    final uri = _packageUri(entity.path);
    sources.add(_SourceFile(uri, _importsOf(entity, uri)));
  }
  return sources;
}

String _packageUri(String path) {
  final relative = p.split(path).skip(1).join('/');
  return 'package:$_packageName/$relative';
}

List<String> _importsOf(File file, String selfUri) {
  return [
    for (final match in _directive.allMatches(file.readAsStringSync()))
      _resolve(match.group(1)!, selfUri),
  ];
}

String _resolve(String directive, String selfUri) {
  if (directive.contains(':')) return directive;
  final selfPath = selfUri.substring('package:$_packageName/'.length);
  final resolved = p.posix.normalize(
    p.posix.join(p.posix.dirname(selfPath), directive),
  );
  return 'package:$_packageName/$resolved';
}

String? _featureOf(String uri) => _feature.firstMatch(uri)?.group(1);

String? _layerOf(String uri) => _layer.firstMatch(uri)?.group(1);

bool _isLayer(String uri, String layer) => _layerOf(uri) == layer;

void _expectNoViolation(
  List<_SourceFile> files, {
  required bool Function(String uri) appliesTo,
  required bool Function(String uri) forbidden,
  required String reason,
}) {
  final violations = <String>[];
  for (final file in files.where((file) => appliesTo(file.uri))) {
    for (final import in file.imports.where(forbidden)) {
      violations.add('${file.uri} -> $import');
    }
  }
  expect(violations, isEmpty, reason: reason);
}
