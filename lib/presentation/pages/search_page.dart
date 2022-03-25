import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:rick_and_morty/presentation/bloc/character_bloc.dart';
import 'package:rick_and_morty/presentation/widgets/custom_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Character _currentCharacter;
  List<Results> _currentResults = [];
  int _currentPage = 1;
  String _currentSearchStr = '';

  final RefreshController refreshController = RefreshController();
  bool _isPaddination = false;

  Timer? searchDebounce;

  final _storage = HydratedBlocOverrides.current?.storage;

  @override
  void initState() {
    if (_storage.runtimeType.toString().isEmpty) {
      //проверка на сохранность состояния приложения
      if (_currentResults.isEmpty) {
        context
            .read<CharacterBloc>()
            .add(const CharacterEvent.fetch(name: '', page: 1));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterBloc>().state;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(86, 86, 86, 0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: 'Search Name',
              hintStyle: const TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              _currentPage = 1;
              _currentResults = [];
              //_currentResults.clear();
              _currentSearchStr = value;

              searchDebounce?.cancel(); //отменяет таймер перед каждым вводом
              searchDebounce = Timer(const Duration(milliseconds: 500), () {
                //таймер перед тем как подать запрос
                context
                    .read<CharacterBloc>()
                    .add(CharacterEvent.fetch(name: value, page: _currentPage));
              });
            },
          ),
        ),
        Expanded(
          child: state.when(
            loading: () {
              if (!_isPaddination) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('Loading...'),
                    ],
                  ),
                );
              } else {
                return _customListView(_currentResults);
              }
            },
            loaded: (characterLoaded) {
              _currentCharacter = characterLoaded;
              if (_isPaddination) {
                _currentResults.addAll(
                    _currentCharacter.results); //добавляет новых 20 персонажей
                refreshController.loadComplete(); //персы готовы к отображению
                _isPaddination = false;
              } else {
                _currentResults =
                    _currentCharacter.results; // иначе отображается первые 20
              }
              return _currentResults.isNotEmpty
                  ? _customListView(_currentResults)
                  : const SizedBox();
            },
            error: () => const Text('Nothing found...'),
          ),
        ),
      ],
    );
  }

  Widget _customListView(List<Results> currentResults) {
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      enablePullDown: false,
      onLoading: () {
        _isPaddination = true;
        ++_currentPage;
        if (_currentPage <= _currentCharacter.info.pages) {
          context.read<CharacterBloc>().add(CharacterEvent.fetch(
              name: _currentSearchStr, page: _currentPage));
        } else {
          refreshController.loadNoData();
        }
      },
      child: ListView.separated(
        itemCount: currentResults.length,
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final result = currentResults[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
            child: CustomListTile(
              result: result,
            ),
          );
        },
      ),
    );
  }
}
