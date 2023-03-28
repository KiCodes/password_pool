import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:password_pool/PasswordModel.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'AppTheme.dart';
import 'database_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Password Pool',
            debugShowCheckedModeBanner: false,
            theme: appState.isDarkMode
                ? darkThemeData(context)
                : lightThemeData(context),
            darkTheme: appState.isDarkMode
                ? darkThemeData(context)
                : lightThemeData(context),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

int randomNumber() {
  Random _random = Random();
  return _random.nextInt(100);
}

String randomNonAlphaNumeric() {
  List<String> characters = [
    '!',
    '@',
    '#',
    '\$',
    '%',
    '^',
    '&',
    '*',
    '-',
    '_',
    '+',
    '=',
    '\\',
    ';',
    ':',
    ',',
    '.',
    '<',
    '>',
    '/',
    '?',
    '`',
    '~'
  ];
  Random random = Random();
  int index1 = random.nextInt(characters.length);
  int index2 = random.nextInt(characters.length);
  while (index2 == index1) {
    index2 = random.nextInt(characters.length);
  }
  return characters[index1] + characters[index2];
}

class MyAppState extends ChangeNotifier {
  String _current = WordPair.random().asPascalCase;
  String _randomNumbers = randomNumber().toString();
  String _randomNonAlpha = randomNonAlphaNumeric();
  bool _isDarkMode = false;
  late int? _lastInsertedPasswordId = -1;

  String last_password = '';

  set lastInsertedPasswordId(int id) {
    _lastInsertedPasswordId = id;
  }

  final _databaseService = DatabaseService();

  String get current => _current;

  void _updateCurrent(String newCurrent) {
    _current = newCurrent;
    notifyListeners();
  }

  void switchTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;

  void getRandomCasing() {
    _updateCurrent(randomCasing());
    _randomNumbers = randomNumber().toString();
    _randomNonAlpha = randomNonAlphaNumeric();

    last_password = "$_current$_randomNumbers$_randomNonAlpha";
    final favorite = Favorite(
        current: _current,
        randomNumbers: _randomNumbers,
        randomNonAlpha: _randomNonAlpha);
    _isFavorited = favorites.contains(favorite);

    notifyListeners();
  }

  String randomCasing() {
    String originalWord = WordPair.random().asPascalCase;
    String newWord = '';
    for (int i = 0; i < originalWord.length; i++) {
      Random random = Random();
      int randomNumber =
          random.nextInt(2); // generate a random number between 0 and 1
      if (randomNumber == 0) {
        newWord += originalWord[i].toLowerCase();
      } else {
        newWord += originalWord[i].toUpperCase();
      }
    }
    return newWord;
  }

  List<Favorite> favorites = [];
  List<PasswordModel> _passwords = [];

  List<PasswordModel> get passwords => _passwords;

  bool _isFavorited = false;

  bool get isFavorited => _isFavorited;

  Future<void> addToFavorites() async {
    final favorite = Favorite(
        current: _current,
        randomNumbers: _randomNumbers,
        randomNonAlpha: _randomNonAlpha);
    final passwords = await _databaseService.getAllPasswords();

    if (passwords.isEmpty){
      favorites.add(favorite);
      final password = PasswordModel(
        password:
        '${favorite.current}${favorite.randomNumbers}${favorite.randomNonAlpha}',
      );
      _isFavorited = true;

      await _databaseService.insertPasswordField(password);
      _lastInsertedPasswordId = password.id; // set _lastInsertedPasswordId
      await _databaseService.getAllPasswords();
    }
    else{
      //This .any will iterate through the passwords list and check if any of its elements have a password property equal to last_password.
      if (passwords.any((p) => p.password == last_password)) {
        favorites.remove(last_password);
        await _databaseService.deletePasswordField(passwords.last.id!);
        await _databaseService.getAllPasswords();
        _isFavorited = false;
        _lastInsertedPasswordId = -1;
      }
      else if (!passwords.any((p) => p.password == last_password)){
        favorites.add(favorite);
        _isFavorited = true;
        final password = PasswordModel(
          password:
          '${favorite.current}${favorite.randomNumbers}${favorite.randomNonAlpha}',
        );

        await _databaseService.insertPasswordField(password);
        _lastInsertedPasswordId = password.id; // set _lastInsertedPasswordId
        await _databaseService.getAllPasswords();
        // await _databaseService.deleteAllField();
      }
    }


    notifyListeners();
  }

  Future<void> removeFromFavorites(int id) async {
    final removeFromFavList = await _databaseService.getPasswordById(id);
    await _databaseService.deletePasswordField(id);
    await _databaseService.getAllPasswords();
    _passwords.removeWhere((password) => password.id == id); // remove from _passwords
    // await _databaseService.deleteAllField();
    favorites.remove(removeFromFavList);

    _isFavorited = false;
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
    final appState = Provider.of<MyAppState>(context);
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = Placeholder();
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
                  icon: Icon(
                    Icons.home,
                    size: 33,
                  ),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite, size: 33),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.login, size: 33),
                  label: Text('Login'),
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
              color: Theme.of(context).colorScheme.background,
              child: page,
            ),
          ),
        ],
      ),
      // switch theme
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                Theme.of(context).brightness == Brightness.light
                    ? 'Light Theme'
                    : 'Dark Theme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Switch(
                value: appState.isDarkMode,
                onChanged: (bool value) {
                  appState.switchTheme();
                }),
          ],
        ),
      ),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text('Password Pool',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          SizedBox(height: 5),
          BigCard(appState: appState),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.addToFavorites();
                },
                icon: Icon(
                  appState.isFavorited ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  appState.isFavorited ? 'Unfavorite' : 'Favourite',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getRandomCasing();
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<PasswordModel> _passwords = [];
  final _databaseService = DatabaseService();
  int? _lastInsertedPasswordId;

  // we want the db passwords to be initialized here with the loadpassword function
  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

// puts the all the passwords into the list _passwords
  Future<void> _loadPasswords() async {
    final passwords = await _databaseService.getAllPasswords();
    setState(() {
      _passwords = passwords;
      if (_passwords.isNotEmpty) {
        _lastInsertedPasswordId = _passwords.last.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final appState = context.watch<MyAppState>();

    if (_passwords.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.tertiary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _passwords.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final password = _passwords[index];
            return Card(
              elevation: 2,
              shadowColor: theme.colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    '${password.password}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                  subtitle: Text('${password.id} ${password.field}'),
                  trailing: GestureDetector(
                    onTap: () {
                      appState.lastInsertedPasswordId = password.id!;
                      appState.removeFromFavorites(password.id!);
                    },
                    child: Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class LoginPage extends StatelessWidget{
//
//
// }

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Card(
        //making the color the theme of the app
        color: theme.colorScheme.tertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), // adding 16 pixels padding around the text
          child: Text(
            appState.current +
                appState._randomNumbers +
                appState._randomNonAlpha,
            style: style,
          ),
        ),
      ),
    );
  }
}

class Favorite {
  final String current;
  final String randomNumbers;
  final String randomNonAlpha;

  Favorite(
      {required this.current,
      required this.randomNumbers,
      required this.randomNonAlpha});

  //When you call favorites.contains(favorite) to check if the password
  // is already in the list, the Favorite class needs to
  // implement operator == and hashCode to compare instances of Favorite.
  // Otherwise, it will always return false, because contains checks for
  // object identity rather than object equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Favorite &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          randomNumbers == other.randomNumbers &&
          randomNonAlpha == other.randomNonAlpha;

  @override
  int get hashCode =>
      current.hashCode ^ randomNumbers.hashCode ^ randomNonAlpha.hashCode;
}
