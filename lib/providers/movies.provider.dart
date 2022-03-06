import 'dart:async';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_response.dart';
import 'package:peliculas/helpers/debouncer.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = '0ee7f690a8ff00f32facdc44e9731b8a';
  final String _baseUrl = 'api.themoviedb.org';
  final String _segmentOnDisplay = '3/movie/now_playing';
  final String _segmentPopular = '3/movie/popular';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> movieCast = {};

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String segment, [int page = 1]) async {
    final url = Uri.https(
      _baseUrl,
      segment,
      {'api_key': _apiKey, 'language': _language, 'page': '$page'},
    );

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData(_segmentOnDisplay);
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    final jsonData = await _getJsonData(_segmentPopular);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    movieCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(
      _baseUrl,
      '3/search/movie',
      {'api_key': _apiKey, 'language': _language, 'query': query},
    );
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      // print('Tenemos valor a buscar: $value');
      final results = await searchMovies(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
