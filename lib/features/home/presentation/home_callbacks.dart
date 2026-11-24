import 'package:bars/features/home/domain/home_sections.dart';
import 'package:bars/features/library/domain/track.dart';

/// Plays [tracks] starting at [index].
typedef PlayTracksCallback = void Function(List<Track> tracks, int index);

/// Plays [tracks] in random order.
typedef ShuffleTracksCallback = void Function(List<Track> tracks);

/// Plays [album] from its first track.
typedef PlayAlbumCallback = void Function(HomeAlbum album);
