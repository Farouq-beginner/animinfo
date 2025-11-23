import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_bloc.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../domain/entities/anime.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearched = false;

  // Filters
  String _genre = 'All';
  String _season = 'All';
  String _studio = 'All';
  String _status = 'All';
  String _type = 'All';
  String _sub = 'All';
  String _orderBy = 'Default';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAnime(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isSearched = true;
      });
      context.read<AnimeBloc>().add(SearchAnimeEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Anime'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            // Search Field + Filter Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for anime...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearched = false;
                          });
                          context.read<AnimeBloc>().add(const SearchAnimeEvent(''));
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: _searchAnime,
                  ),
                ),
                SizedBox(width: 2.w),
                OutlinedButton.icon(
                  onPressed: () => _openFilters(context),
                  icon: const Icon(Icons.list),
                  label: const Text('Anime List'),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Search Results
            Expanded(
              child: BlocConsumer<AnimeBloc, AnimeState>(
                listener: (context, state) {
                  if (state is AnimeError && _isSearched) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildContent(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AnimeState state) {
    if (!_isSearched) {
      return Center(
        child: Text(
          'Search for your favorite anime',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    if (state is AnimeLoading) {
      return const LoadingWidget();
    } else if (state is SearchAnimeLoaded) {
      // Apply filters and sorting
      final filtered = _applyFilters(state.animeList);
      if (filtered.isEmpty) {
        return _buildEmptyState('No results found');
      }
      return _buildAnimeGrid(filtered);
    } else if (state is AnimeError) {
      return _buildErrorState();
    }
    if (state is TopAnimeLoaded) {
      return Center(
        child: Text(
          'Search for your favorite anime',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return _buildEmptyState('No search results');
  }

  List<Anime> _applyFilters(List<Anime> source) {
    Iterable<Anime> result = source;

    // Genre
    if (_genre != 'All') {
      result = result.where((a) =>
          (a.genres ?? const [])
              .any((g) => g.name.toLowerCase() == _genre.toLowerCase()));
    }

    // Season
    if (_season != 'All') {
      result = result.where((a) => (a.season ?? '').toLowerCase() == _season.toLowerCase());
    }

    // Studio
    if (_studio != 'All') {
      result = result.where((a) =>
          (a.studios ?? const [])
              .any((s) => s.name.toLowerCase() == _studio.toLowerCase()));
    }

    // Status
    if (_status != 'All') {
      result = result.where((a) => (a.status ?? '').toLowerCase() == _status.toLowerCase());
    }

    // Type
    if (_type != 'All') {
      result = result.where((a) => (a.type ?? '').toLowerCase() == _type.toLowerCase());
    }

    // Sub (placeholder - no field available; keep as All)

    // Order by
    List<Anime> list = result.toList();
    switch (_orderBy) {
      case 'Score':
        list.sort((a, b) => (b.score ?? -1).compareTo(a.score ?? -1));
        break;
      case 'Popularity':
        list.sort((a, b) {
          final ap = a.popularity ?? 1 << 30;
          final bp = b.popularity ?? 1 << 30;
          return ap.compareTo(bp); // lower popularity rank is better
        });
        break;
      case 'Favorites':
        list.sort((a, b) => (b.favorites ?? 0).compareTo(a.favorites ?? 0));
        break;
      case 'Title':
        list.sort((a, b) => (a.title).toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Year':
        list.sort((a, b) => (b.year ?? -1).compareTo(a.year ?? -1));
        break;
      default:
        // Default (keep API order)
        break;
    }

    return list;
  }

  void _openFilters(BuildContext context) {
    // Build option lists from the latest SearchAnimeLoaded state if available
    final state = context.read<AnimeBloc>().state;
    final List<Anime> baseList = state is SearchAnimeLoaded ? state.animeList : const [];

    final genres = <String>{'All'};
    final seasons = <String>{'All'};
    final studios = <String>{'All'};
    final statuses = <String>{'All'};
    final types = <String>{'All'};

    for (final a in baseList) {
      for (final g in (a.genres ?? const [])) {
        if (g.name.trim().isNotEmpty) genres.add(g.name);
      }
      for (final s in (a.studios ?? const [])) {
        if (s.name.trim().isNotEmpty) studios.add(s.name);
      }
      if ((a.season ?? '').trim().isNotEmpty) seasons.add(a.season!.substring(0,1).toUpperCase()+a.season!.substring(1).toLowerCase());
      if ((a.status ?? '').trim().isNotEmpty) statuses.add(a.status!);
      if ((a.type ?? '').trim().isNotEmpty) types.add(a.type!);
    }

    final orderByOptions = const [
      'Default', 'Score', 'Popularity', 'Favorites', 'Title', 'Year'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h + MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              DropdownButtonFormField<String> buildDropdown(
                {required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
                  return DropdownButtonFormField<String>(
                    value: items.contains(value) ? value : items.first,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setModalState(() => onChanged(v)),
                  );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Filters', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2.h),
                    buildDropdown(label: 'Genre', value: _genre, items: genres.toList()..toList().sort(), onChanged: (v){ if(v!=null) _genre=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Season', value: _season, items: seasons.toList()..toList().sort(), onChanged: (v){ if(v!=null) _season=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Studio', value: _studio, items: studios.toList()..toList().sort(), onChanged: (v){ if(v!=null) _studio=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Status', value: _status, items: statuses.toList()..toList().sort(), onChanged: (v){ if(v!=null) _status=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Type', value: _type, items: types.toList()..toList().sort(), onChanged: (v){ if(v!=null) _type=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Sub', value: _sub, items: const ['All','Sub','Dub'], onChanged: (v){ if(v!=null) _sub=v; }),
                    SizedBox(height: 1.2.h),
                    buildDropdown(label: 'Order by', value: _orderBy, items: orderByOptions, onChanged: (v){ if(v!=null) _orderBy=v; }),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: () { setState(() {}); Navigator.pop(context); },
                      icon: const Icon(Icons.check),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _genre = 'All';
                          _season = 'All';
                          _studio = 'All';
                          _status = 'All';
                          _type = 'All';
                          _sub = 'All';
                          _orderBy = 'Default';
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimeGrid(List<Anime> animeList) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        return AnimeCard(
          anime: anime,
          onTap: () {
            context.push('/detail', extra: anime.malId);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    // ... (Fungsi ini biarkan sama) ...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: Colors.red[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'Error searching anime',
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchAnime(_searchController.text);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}