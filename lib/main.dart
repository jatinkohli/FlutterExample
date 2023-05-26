import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          scrollbarTheme: ScrollbarThemeData(
            trackVisibility: MaterialStateProperty.resolveWith((states) => true),
            thumbVisibility: MaterialStateProperty.resolveWith((states) => true),
          )
        ),
        home: MyHomePage()
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        double margin = min(height, width) * 0.10;

        return Column(
          children: [
            SizedBox(height: height * 0.08),
            Text(
              'Saved Names:',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(margin),
              child: Container(
                height: height * 0.65,
                child: SingleChildScrollView(
                  child: GridView.count(
                    crossAxisCount: width ~/ 250,
                    shrinkWrap: true,
                    children: [
                      for (var element in appState.favorites)
                      FavoritesCard(
                        pair: element
                      )
                    ]
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A random name idea:',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              SizedBox(
                height: height * 0.2,
                width: width * 0.3,
                child: BigCard(pair: pair),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => {appState.getNext()},
                      icon: Icon(Icons.arrow_circle_right),
                      label: Text('Next'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => {appState.toggleFavorite()}, 
                      icon: Icon(icon),
                      label: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: AutoSizeText(
            pair.asLowerCase,
            style: style,
            maxLines: 1,
            minFontSize: 8,
            semanticsLabel: "${pair.first} ${pair.second}",
          ),
        ),
      ),
    );
  }
}

class FavoritesCard extends StatelessWidget {
  const FavoritesCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold
    );

    var appState = context.watch<MyAppState>();

    return Card(
      color: theme.colorScheme.primary,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: AutoSizeText(
                pair.asLowerCase,
                style: style,
                maxLines: 1,
                minFontSize: 8,
                semanticsLabel: "${pair.first} ${pair.second}",
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete $pair?'),
                      actions: [
                        ElevatedButton(
                          child: Text('Delete'),
                          onPressed: () {
                            appState.removeFavorite(pair);
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
                );
              },
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 121, 5, 5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}