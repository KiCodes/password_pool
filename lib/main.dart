import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:password_pool/models/PasswordModel.dart';
import 'package:password_pool/pages/InstructionsPage.dart';
import 'package:password_pool/pages/generator.dart';
import 'package:password_pool/pages/settings.dart';
import 'package:password_pool/pages/splash.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/AppTheme.dart';
import 'utils/constants.dart';
import 'pages/EditPasswordField.dart';
import 'database/database_service.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

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
            title: Texts.title,
            debugShowCheckedModeBanner: false,
            theme: appState.isDarkMode
                ? darkThemeData(context)
                : lightThemeData(context),
            darkTheme: appState.isDarkMode
                ? darkThemeData(context)
                : lightThemeData(context),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashPage(),
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String _current = WordPair.random().asPascalCase;
  String _randomNumbers = randomNumber().toString();
  String _randomNonAlpha = randomNonAlphaNumeric();
  bool _isDarkMode = false;
  bool depth_illusion = false;
  late int? _lastInsertedPasswordId = -1;

  String last_password = '';

  //lockscren
  final bool _isPasswordEnabled = false;
  bool get isPasswordEnabled => _isPasswordEnabled;

  String _lockPass = '';
  String get lockpass => _lockPass;

  set lockpass(String lockpass) {
    _lockPass = lockpass;
  }


  set isPasswordEnabled(bool _isPasswordEnabled) {
    _isPasswordEnabled = false;
  }

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
    return originalWord;
  }

  List<Favorite> favorites = [];
  List<PasswordModel> _passwords = [];

  List<PasswordModel> get passwords => _passwords;

  bool _isFavorited = false;

  bool get isFavorited => _isFavorited;

  void setPasswords(List<PasswordModel> passwords) {
    _passwords = passwords;
    notifyListeners();
  }

  Future<void> addToFavorites() async {
    final favorite = Favorite(
        current: _current,
        randomNumbers: _randomNumbers,
        randomNonAlpha: _randomNonAlpha);
    final passwords = await _databaseService.getAllPasswords();
    final password = PasswordModel(
      password:
          '${favorite.current}${favorite.randomNumbers}${favorite.randomNonAlpha}',
    );

    if (passwords.isEmpty) {
      favorites.add(favorite);
      await _databaseService.insertPasswordField(password);
      final pss = await _databaseService.getAllPasswords();
      setPasswords(pss);
      _lastInsertedPasswordId =
          _passwords.last.id; // set _lastInsertedPasswordId
      _isFavorited = true;
    } else {
      //This .any will iterate through the passwords list and check if any of its elements have a password property equal to last_password.
      if (_isFavorited) {
        favorites.remove(last_password);
        _passwords.remove(password);
        await _databaseService.deletePasswordField(_passwords.last.id!);
        _isFavorited = false;
      } else if (!passwords.any((p) => p.password == last_password)) {
        favorites.add(favorite);
        await _databaseService.insertPasswordField(password);
        final pss = await _databaseService.getAllPasswords();
        setPasswords(pss);
        _lastInsertedPasswordId = _passwords.last.id;
        _isFavorited = true;
      }
    }

    notifyListeners();
  }

  Future<void> removeFromFavorites(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Texts.remove_password),
          content: Text(Texts.sure_rmv_password),
          actions: [
            TextButton(
              child: Text(Texts.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(Texts.remove),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    print(confirmed);

    if (confirmed == true) {
      print(id);
      final removeFromFavList = await _databaseService.getPasswordById(id);
      if (removeFromFavList != null) {
        await _databaseService.deletePasswordField(id);
        _passwords.remove(removeFromFavList); // remove from _passwords
        favorites.remove(removeFromFavList!.password);
        setPasswords(_passwords);

        if (removeFromFavList!.password == last_password) {
          _isFavorited = false;
        }
      }
    }

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
    final theme = Theme.of(context).colorScheme;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final maxWidth = MediaQuery.of(context).size.width;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = const InstructionsPage();
        break;
      case 3:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(22)),
        depth: 3,
        lightSource: LightSource.topLeft,
        // color: !appState.isDarkMode ? Colors.lightBlueAccent : Colors.black12,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: !appState.isDarkMode
                  ? [Colors.lightBlueAccent, Colors.blue]
                  : [Colors.black12, Colors.black45],
            ),
          ),
          child: Row(
            children: [
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (isLandscape == true) {
                      if(maxWidth > 1024){
                        print(maxWidth);
                        return buildNavigationRail(theme, 77.0, 40.0, 0.0);
                      }
                      if(maxWidth > 768){
                        print(maxWidth);
                        return buildNavigationRail(theme, 55.0, 36.0, 0.0);
                      }
                      if(maxWidth > 480){
                        print(maxWidth);
                        return buildNavigationRail(theme, 48.0, 32.0, 0.0);
                      }
                      else{
                        print(maxWidth);
                        return buildNavigationRail(theme, 50.0, 32.0, 0.0);
                      }

                    }
                    else{
                      if(maxWidth >= 1024){
                        print(maxWidth);
                        return buildNavigationRail(theme, 90.0, 55.0, 0.0);
                      }
                      if(maxWidth >= 768){
                        print(maxWidth);
                        return buildNavigationRail(theme, 90.0, 55.0, 0.0);
                      }
                      if(maxWidth >= 480){
                        print(maxWidth);
                        return buildNavigationRail(theme, 77.0, 34.0, 0.0);
                      }
                      if(maxWidth >= 200){
                        print(maxWidth);
                        return buildNavigationRail(theme, 57.0, 34.0, -1.0);
                      }
                      else{
                        print(maxWidth);
                        return buildNavigationRail(theme, 55.0, 33.0, -1.0);
                      }
                    }
                  }
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
                      ? Texts.light_theme
                      : Texts.dark_theme,
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
                  },
                  activeColor: theme.primary),
            ],
          ),
        ),
      ),
    );
  }

  NavigationRail buildNavigationRail(ColorScheme theme, minWidth, iconSize, groupA) {
    return NavigationRail(
                    backgroundColor: theme.tertiary,
                    extended: false,
                    destinations: [
                      NavigationRailDestination(
                        icon: NeumorphicIcon(Icons.home,
                            size: iconSize,
                            style: NeumorphicStyle(
                              color:
                                  selectedIndex == 0 ? theme.primary : Colors.white,
                              depth: selectedIndex == 0 ? 0 : 3,
                              shape: NeumorphicShape.flat,
                              intensity: 7,
                            )),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: NeumorphicIcon(Icons.favorite,
                            size: iconSize,
                            style: NeumorphicStyle(
                              color:
                                  selectedIndex == 1 ? theme.primary : Colors.white,
                              depth: selectedIndex == 1 ? 0 : 3,
                              shape: NeumorphicShape.flat,
                              intensity: 7,
                            )),
                        label: Text(Texts.favorites),
                      ),
                      NavigationRailDestination(
                        icon: NeumorphicIcon(Icons.help,
                            size: iconSize,
                            style: NeumorphicStyle(
                              color:
                                  selectedIndex == 2 ? theme.primary : Colors.white,
                              depth: selectedIndex == 2 ? 0 : 3,
                              shape: NeumorphicShape.flat,
                              intensity: 7,
                            )),
                        label: Text(Texts.login),
                      ),
                      NavigationRailDestination(
                        icon: NeumorphicIcon(Icons.settings,
                            size: iconSize,
                            style: NeumorphicStyle(
                              color:
                                  selectedIndex == 3 ? theme.primary : Colors.white,
                              depth: selectedIndex == 3 ? 0 : 3,
                              shape: NeumorphicShape.flat,
                              intensity: 7,
                            )),
                        label: Text(Texts.login),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
      groupAlignment: groupA,
                    minWidth: minWidth,
                  );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _databaseService = DatabaseService();
  int? _lastInsertedPasswordId;
  bool _isPasswordEnabled = false;
  String lockpass = '';

  // we want the db passwords to be initialized here with the loadpassword function
  @override
  void initState() {
    super.initState();
    _loadState();
    _loadPasswords();
  }
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPasswordEnabled = prefs.getBool('isPasswordEnabled') ?? false;
      lockpass = prefs.getString('lockpass') ?? '';
      print("${lockpass} ii");
    });
  }

// puts the all the passwords into the list _passwords
  Future<void> _loadPasswords() async {
    final appState = context.read<MyAppState>();
    final passwords = await _databaseService.getAllPasswords();
    setState(() {
      appState.setPasswords(passwords);
      if (passwords.isNotEmpty) {
        _lastInsertedPasswordId = passwords.last.id;
      }
    });
  }

  void updatePasswords(List<PasswordModel> passwords) {
    setState(() {
      final appState = context.read<MyAppState>();
      appState._passwords = passwords;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final appState = context.watch<MyAppState>();
    final appStatepasswords = appState.passwords;
    final maxWidth = MediaQuery.of(context).size.width;

    void _togglePasswordVisibility(int index) {
      setState(() {
        appStatepasswords[index].visible = !appStatepasswords[index].visible;
      });
    }

    void _toggleEditIllusion(int index) {
      setState(() {
        appStatepasswords[index].editing = !appStatepasswords[index].editing;
      });
    }

    void _handleModalBottomSheetDismissed(BuildContext context) {
      // Find the index of the password that was being edited
      int index = appStatepasswords.indexWhere((password) => password.editing);

      if (index >= 0) {
        // Change the editing property of the corresponding password object
        setState(() {
          appStatepasswords[index].editing = false;
        });
      }
    }

    void _toggleHeartIllusion(int index) {
      setState(() {
        appStatepasswords[index].heart = !appStatepasswords[index].heart;
      });
    }

    void _HeartRemoveButtonUI(BuildContext context) {
      // Find the index of the password that was being edited
      int index = appStatepasswords.indexWhere((password) => password.heart);

      if (index >= 0) {
        // Change the editing property of the corresponding password object
        setState(() {
          appStatepasswords[index].heart = false;
        });
      }
    }



    if (appStatepasswords.isEmpty) {
      return Center(
        child: Text(Texts.no_favs_yet),
      );
    }

    return _isPasswordEnabled // check if the screen is locked
        ? ScreenLock(
      correctString: lockpass,
      // set the correct PIN
      onUnlocked: () {
        setState(() {
          _isPasswordEnabled = false;// set the state to unlocked when correct PIN is entered
        });
      },
    )
        :
      Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(Texts.favs),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: !appState.isDarkMode
                ? [Colors.lightBlueAccent, Colors.blue]
                : [Colors.black12, Colors.black45],
          )),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (maxWidth >= 1024) {

            return buildContainer(appState, appStatepasswords, theme, _togglePasswordVisibility, _toggleEditIllusion, _handleModalBottomSheetDismissed, _toggleHeartIllusion, _HeartRemoveButtonUI, 47.0, 45.0, 350.0);
          } else if (maxWidth >= 768) {

            return buildContainer(appState, appStatepasswords, theme, _togglePasswordVisibility, _toggleEditIllusion, _handleModalBottomSheetDismissed, _toggleHeartIllusion, _HeartRemoveButtonUI, 44.0, 44.0, 350.0);
          } else if (maxWidth >= 480) {

            return buildContainer(appState, appStatepasswords, theme, _togglePasswordVisibility, _toggleEditIllusion, _handleModalBottomSheetDismissed, _toggleHeartIllusion, _HeartRemoveButtonUI, 22.0, 20.0, 330.0);
          }else if (maxWidth >= 250) {

            return buildContainer(appState, appStatepasswords, theme, _togglePasswordVisibility, _toggleEditIllusion, _handleModalBottomSheetDismissed, _toggleHeartIllusion, _HeartRemoveButtonUI, 22.0, 18.0, 270.0);
          }
          else {

            return buildContainer(appState, appStatepasswords, theme, _togglePasswordVisibility, _toggleEditIllusion, _handleModalBottomSheetDismissed, _toggleHeartIllusion, _HeartRemoveButtonUI, 12.0, 18.0, 270.0);
          }
        }
      ),
    );
  }

  Container buildContainer(MyAppState appState, List<PasswordModel> appStatepasswords, ThemeData theme, void _togglePasswordVisibility(int index), void _toggleEditIllusion(int index), void _handleModalBottomSheetDismissed(BuildContext context), void _toggleHeartIllusion(int index), void _HeartRemoveButtonUI(BuildContext context), iconSize, textSize, height) {
    return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: !appState.isDarkMode
                ? [Colors.lightBlueAccent, Colors.blue]
                : [Colors.black12, Colors.black45],
          )),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: appStatepasswords.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final password = appStatepasswords[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, size: iconSize, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    appState.lastInsertedPasswordId = password.id!;
                    appState
                        .removeFromFavorites(context, password.id!)
                        .then((value) {
                      _loadPasswords();
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (password.visible == true) {
                        // copy password to clipboard when card is tapped
                        Clipboard.setData(ClipboardData(text: password.password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(Texts.pass_copied),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      height: height,
                      child: Card(
                        elevation: 2,
                        shadowColor: theme.colorScheme.tertiary,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(22)),
                                depth: 3,
                                lightSource: LightSource.bottom,
                                border: NeumorphicBorder(
                                  width: 4.3,
                                  color:
                                      theme.colorScheme.onPrimary.withOpacity(0.5),
                                  isEnabled: !password.visible ? true : false,
                                ),
                                color: theme.colorScheme.primary.withOpacity(0.8)),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: SizedBox(
                                height: height,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: theme.colorScheme.secondary
                                                  .withOpacity(0.3),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(
                                                password.visible
                                                    ? '${password.password}'
                                                    : '•••••••••••',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: textSize,
                                                    color: theme.colorScheme.onPrimary),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${password.field}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: textSize,
                                                color: theme.colorScheme.onPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _togglePasswordVisibility(index);
                                            },
                                            child: NeumorphicIcon(
                                              password.visible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size: iconSize,
                                              style: NeumorphicStyle(
                                                color: !appState.isDarkMode
                                                    ? Color(0xFFFFFFFF)
                                                    : Color(0x8A000000),
                                                depth: 3,
                                                shape: NeumorphicShape.flat,
                                                disableDepth:
                                                    password.visible ? true : false,
                                                intensity: 33,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _toggleEditIllusion(index);
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return EditPasswordPage(
                                                    password: password,
                                                    databaseService: _databaseService,
                                                    updatePasswords: updatePasswords,
                                                  );
                                                },
                                              ).then((value) {
                                                _handleModalBottomSheetDismissed(
                                                    context);
                                              });
                                            },
                                            child: NeumorphicIcon(
                                              Icons.edit,
                                              size: iconSize,
                                              style: NeumorphicStyle(
                                                color: !appState.isDarkMode
                                                    ? Color(0xFFFFFFFF)
                                                    : Color(0x8A000000),
                                                depth: 3,
                                                shape: NeumorphicShape.flat,
                                                disableDepth:
                                                    password.editing ? true : false,
                                                intensity: 33,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          GestureDetector(
                                            onTap: () {
                                              _toggleHeartIllusion(index);
                                              appState.lastInsertedPasswordId =
                                                  password.id!;
                                              appState
                                                  .removeFromFavorites(
                                                      context, password.id!)
                                                  .then((value) {
                                                _loadPasswords();
                                                _HeartRemoveButtonUI(context);
                                              });
                                            },
                                            child: NeumorphicIcon(
                                              Icons.favorite,
                                              size: iconSize,
                                              style: NeumorphicStyle(
                                                color: !appState.isDarkMode
                                                    ? Color(0xFFFFFFFF)
                                                    : Color(0x8A000000),
                                                depth: 3,
                                                shape: NeumorphicShape.flat,
                                                disableDepth:
                                                    password.heart ? true : false,
                                                intensity: 33,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.appState,
  }) : super(key: key);

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return cardMethod(theme, 50.0);
        } else if (constraints.maxWidth >= 768) {
          return cardMethod(theme, 40.0);
        } else if (constraints.maxWidth >= 480) {
          return cardMethod(theme, 30.0);
        }
        else if (constraints.maxWidth >= 200) {
          return cardMethod(theme, 10.0);
        } else {
          return cardMethod(theme, 8.0);
        }
      }
    );
  }

  Padding cardMethod(ThemeData theme, fontSize) {
    return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          //making the color the theme of the app
          color: theme.colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orangeAccent, Colors.deepOrangeAccent]),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // adding 16 pixels padding around the text
              child: Text(
                appState.current +
                    appState._randomNumbers +
                    appState._randomNonAlpha,
                style: theme.textTheme.displayMedium!.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold),
              ),
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
