import 'dart:async';
import 'package:flutter/material.dart';
import '../services/anime_api_service.dart';
import '../models/anime.dart';
import '../models/anime_page.dart';
import 'anime_detail_page.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  _AnimeListPageState createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  final AnimeApiService apiService = AnimeApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Anime> _items = [];
  int _page = 1;
  bool _hasNext = true;
  bool _loading = false;
  String _query = '';
  String? _type; // tv, movie, ova, ona, special, music
  String? _orderBy = 'score';
  String? _sort = 'desc';

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
            tooltip: 'Filters',
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(reset: true),
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_loading && _items.isEmpty) {
      return const Center(child: Text('No results'));
    }
    final cross = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        childAspectRatio: 0.7,
      ),
      itemCount: _items.length + (_hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          // loader at end
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
        }
        final anime = _items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimeDetailPage(malId: anime.malId),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    anime.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (!_hasNext || _loading) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _load();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim();
      _load(reset: true);
    });
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (reset) {
        _page = 1;
        _items = [];
        _hasNext = true;
      }
      final AnimePage page = await apiService.fetchAnimePage(
        page: _page,
        q: _query.isEmpty ? null : _query,
        type: _type,
        orderBy: _orderBy,
        sort: _sort,
        sfw: true,
      );
      setState(() {
        _items.addAll(page.data);
        _hasNext = page.hasNextPage;
        _page += 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Type:'),
                  const SizedBox(width: 16),
                  DropdownButton<String?>(
                    value: _type,
                    hint: const Text('Any'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any')),
                      DropdownMenuItem(value: 'tv', child: Text('TV')),
                      DropdownMenuItem(value: 'movie', child: Text('Movie')),
                      DropdownMenuItem(value: 'ova', child: Text('OVA')),
                      DropdownMenuItem(value: 'ona', child: Text('ONA')),
                      DropdownMenuItem(value: 'special', child: Text('Special')),
                      DropdownMenuItem(value: 'music', child: Text('Music')),
                    ],
                    onChanged: (v) => setState(() => _type = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Order by:'),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _orderBy,
                    items: const [
                      DropdownMenuItem(value: 'score', child: Text('Score')),
                      DropdownMenuItem(value: 'rank', child: Text('Rank')),
                      DropdownMenuItem(value: 'popularity', child: Text('Popularity')),
                      DropdownMenuItem(value: 'favorites', child: Text('Favorites')),
                      DropdownMenuItem(value: 'title', child: Text('Title')),
                      DropdownMenuItem(value: 'start_date', child: Text('Start date')),
                      DropdownMenuItem(value: 'episodes', child: Text('Episodes')),
                    ],
                    onChanged: (v) => setState(() => _orderBy = v),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _sort,
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('Desc')),
                      DropdownMenuItem(value: 'asc', child: Text('Asc')),
                    ],
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _load(reset: true);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
