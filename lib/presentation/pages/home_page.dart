import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/ad_state.dart';
import 'package:rick_and_morty/data/repositories/character_repo.dart';
import 'package:rick_and_morty/presentation/bloc/character_bloc.dart';
import 'package:rick_and_morty/presentation/pages/search_page.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({required this.title}); // : super(key: key);

  @override
  _HomePage createState() => _HomePage(title: title);
}

class _HomePage extends State<HomePage> {
  final String title;
  final CharacterRepo repository = CharacterRepo();

  //_HomePage(this.title);
  _HomePage({required this.title}); // : super(key: key);

  late BannerAd banner;

  @override
  void didChangeDependencies() {
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: adState.bannerAdListener,
        )..load();
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        centerTitle: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            if (banner == null)
              const SizedBox(
                height: 50,
              )
            else
              Container(
                height: 50,
                child: AdWidget(ad: banner),
              ),
            BlocProvider(
              create: (context) => CharacterBloc(characterRepo: repository),
              child: Container(
                decoration: const BoxDecoration(color: Colors.black87),
                child: const SearchPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
