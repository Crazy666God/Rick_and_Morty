import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/presentation/bloc/character_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    context
        .read<CharacterBloc>()
        .add(const CharacterEvent.fetch(name: '', page: 1));
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterBloc>().state;
    return state.when(
      loading: () {
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
      },
      loaded: (characterLoaded) => Text('${characterLoaded.info}'),
      error: () => const Text('Nothing found...'),
    );
  }
}