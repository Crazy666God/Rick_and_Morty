import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/ad_state.dart';
import 'package:rick_and_morty/presentation/pages/home_page.dart';
import 'package:rick_and_morty/bloc_observable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // этот виджет используется для взаимодействия с движком флаттер, т.е. соединяет фреймворк и движок флаттер, так как пакету path_provider потребуется создавать хранилище для андройд и ios то он будет использывать каналы платформы для вызова собственного кода который будет выполняться асинхронно и для того чтобы он мог вызвать собственный код нужен этот метод

  final storage = await HydratedStorage.build(
    storageDirectory:
        await getTemporaryDirectory(), // находится в библиотеки path_provider
  ); // т.е. будем хранить состояние во временных папках

  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);

  HydratedBlocOverrides.runZoned(
    () => runApp(
      Provider.value(
        value: adState,
        builder: (context, child) => const MyApp(),
      ),
    ),
    blocObserver: CharacterBlocObservable(),
    storage: storage,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          headline1: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
          headline2: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
          headline3: TextStyle(fontSize: 24.0, color: Colors.white),
          bodyText1: TextStyle(
              fontSize: 12.0, fontWeight: FontWeight.w200, color: Colors.white),
          bodyText2: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white),
          caption: TextStyle(
              fontSize: 11.0, fontWeight: FontWeight.w100, color: Colors.grey),
        ),
      ),
      home: HomePage(title: 'Rick and Morty'),
    );
  }
}
