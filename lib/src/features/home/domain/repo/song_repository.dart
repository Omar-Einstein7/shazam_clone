import 'package:flutter_complete_project/src/features/home/domain/entities/song.dart';



abstract class SongRepository {
  Future<Song> recognizeSong(String audioPath);
}