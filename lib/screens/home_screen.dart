import 'package:flutter/material.dart';
import 'package:peliculas/helpers/search_delegate.dart';

import 'package:provider/provider.dart';
import 'package:peliculas/providers/movies.provider.dart';

import 'package:peliculas/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Películas en cines'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => showSearch(
              context: context,
              delegate: MovieSearchDelegate(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tarjetas principales
            const SizedBox(height: 50),
            CardSwiper(movies: moviesProvider.onDisplayMovies),

            // Slider de películas populares
            const SizedBox(height: 40),
            MovieSlider(
              movies: moviesProvider.popularMovies,
              title: 'Populares!',
              onNextPage: () => moviesProvider.getPopularMovies(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
