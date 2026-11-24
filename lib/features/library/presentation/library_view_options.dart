import 'package:bars/features/library/domain/track_sort.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_view_options.g.dart';

/// How the library list is ordered and what each row shows.
class LibraryViewOptions {
  /// Creates options; the defaults match a title A-Z list.
  const new({this.sort = TrackSort.titleAscending, this.showDuration = false});

  /// Order of the list.
  final TrackSort sort;

  /// Whether every row shows the track length.
  final bool showDuration;

  /// Returns a copy with the given fields replaced.
  LibraryViewOptions copyWith({TrackSort? sort, bool? showDuration}) {
    return LibraryViewOptions(
      sort: sort ?? this.sort,
      showDuration: showDuration ?? this.showDuration,
    );
  }
}

/// Keeps the chosen library options while the app is running.
@Riverpod(keepAlive: true)
class LibraryViewOptionsNotifier extends _$LibraryViewOptionsNotifier {
  @override
  LibraryViewOptions build() => const LibraryViewOptions();

  /// Reorders the list.
  void setSort(TrackSort sort) => state = state.copyWith(sort: sort);

  /// Shows or hides the track length in every row.
  void setShowDuration(bool show) => state = state.copyWith(showDuration: show);
}
