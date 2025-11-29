import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_cubit.dart';
import '../blocs/anime/anime_state.dart';
import '../blocs/authentication/authentication_cubit.dart';
import '../blocs/authentication/authentication_state.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/anime.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Simpan state filter lokal
  String _selectedGenre = 'All';
  String _selectedStudio = 'All';
  String _selectedStatus = 'All';
  String _selectedSort = 'Score High-Low';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomePage: Initializing and fetching anime');
      _fetchAnime();
    });
  }

  void _fetchAnime() {
    print('🔄 HomePage: Fetching anime...');
    try {
      if (context.read<AnimeCubit>().state is! TopAnimeLoaded) {
        context.read<AnimeCubit>().getTopAnime();
      }
    } catch (e) {
      print('❌ HomePage: Error fetching anime: $e');
      _showErrorSnackBar('Failed to fetch anime: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedGenre = 'All';
                _selectedStudio = 'All';
                _selectedStatus = 'All';
                _selectedSort = 'Score High-Low';
              });
              context.read<AnimeCubit>().getTopAnime();
            },
          ),
        ],
      ),
      body: BlocConsumer<AnimeCubit, AnimeState>(
        listener: (context, state) {
          if (state is AnimeError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return _buildScrollableBody(state);
        },
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final state = context.read<AnimeCubit>().state;
    List<Anime> currentList = [];
    if (state is TopAnimeLoaded) {
      currentList = state.animeList;
    }

    final Set<String> genres = {'All'};
    final Set<String> studios = {'All'};
    final Set<String> statuses = {'All'};

    for (var anime in currentList) {
      // PERBAIKAN: Akses .name dari Object Genre & Studio
      if (anime.genres != null) {
        for (var g in anime.genres!) {
          genres.add(g.name);
        }
      }
      if (anime.studios != null) {
        for (var s in anime.studios!) {
          studios.add(s.name);
        }
      }
      if (anime.status != null) statuses.add(anime.status!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 5.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    _buildDropdown(
                      label: 'Sort By',
                      value: _selectedSort,
                      items: [
                        'Score High-Low',
                        'Score Low-High',
                        'Title A-Z'
                      ],
                      onChanged: (val) {
                        setModalState(() => _selectedSort = val!);
                      },
                    ),
                    SizedBox(height: 2.h),

                    _buildDropdown(
                      label: 'Genre',
                      value: genres.contains(_selectedGenre) ? _selectedGenre : 'All',
                      items: genres.toList()..sort(),
                      onChanged: (val) {
                        setModalState(() => _selectedGenre = val!);
                      },
                    ),
                    SizedBox(height: 2.h),

                    _buildDropdown(
                      label: 'Studio',
                      value: studios.contains(_selectedStudio) ? _selectedStudio : 'All',
                      items: studios.toList()..sort(),
                      onChanged: (val) {
                        setModalState(() => _selectedStudio = val!);
                      },
                    ),
                    SizedBox(height: 2.h),

                    _buildDropdown(
                      label: 'Status',
                      value: statuses.contains(_selectedStatus) ? _selectedStatus : 'All',
                      items: statuses.toList()..sort(),
                      onChanged: (val) {
                        setModalState(() => _selectedStatus = val!);
                      },
                    ),
                    SizedBox(height: 4.h),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedGenre = 'All';
                                _selectedStudio = 'All';
                                _selectedStatus = 'All';
                                _selectedSort = 'Score High-Low';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              side: BorderSide(color: Colors.blue[900]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AnimeCubit>().applyFilterAndSort(
                                genre: _selectedGenre,
                                studio: _selectedStudio,
                                status: _selectedStatus,
                                sortBy: _selectedSort,
                              );
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      ),
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildScrollableBody(AnimeState state) {
    if (state is AnimeLoading || state is AnimeInitial) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeCubit>().getTopAnime();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverToBoxAdapter(child: SizedBox(height: 1.h)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: const LoadingWidget(),
            ),
          ],
        ),
      );
    } else if (state is TopAnimeLoaded) {
      if (state.animeList.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AnimeCubit>().getTopAnime();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildWelcomeCard()),
              SliverToBoxAdapter(child: SizedBox(height: 1.h)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState('No anime found'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeCubit>().getTopAnime();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverPadding(
              padding: EdgeInsets.all(2.w),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final anime = state.animeList[index];
                    return AnimeCard(
                      anime: anime,
                      onTap: () {
                        context.push('/detail', extra: anime.malId);
                      },
                    );
                  },
                  childCount: state.animeList.length,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is AnimeError) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeCubit>().getTopAnime();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverToBoxAdapter(child: SizedBox(height: 1.h)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(state.message),
            ),
          ],
        ),
      );
    }
    _fetchAnime();
    return const LoadingWidget();
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, authState) {
          String name = 'User';
          if (authState is AuthenticationAuthenticated) {
            name = authState.user.username;
          }
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.2.h),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Icon(
                        Icons.person_outline,
                        size: 10.w,
                        color:Color(0xFF0D47A1)
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tv_off, size: 20.w, color: Colors.grey[400]),
          SizedBox(height: 2.h),
          Text(message, style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]), textAlign: TextAlign.center),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              context.read<AnimeCubit>().getTopAnime();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 20.w, color: Colors.red[400]),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text('Error loading data', style: TextStyle(fontSize: 16.sp), textAlign: TextAlign.center),
          ),
          SizedBox(height: 1.h),
          Text(message, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), textAlign: TextAlign.center),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              context.read<AnimeCubit>().getTopAnime();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}