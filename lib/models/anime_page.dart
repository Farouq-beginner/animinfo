import 'anime.dart';

class AnimePage {
  final List<Anime> data;
  final bool hasNextPage;
  final int? currentPage;

  const AnimePage({
    required this.data,
    required this.hasNextPage,
    this.currentPage,
  });
}
