import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:password_pool/main.dart';
import 'package:password_pool/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPasswordEnabled = false;
  bool _isPasswordVisible = false;
  String _password = '';
  String _confirmPassword = '';
  String lockpass = '';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final appState = context.read<MyAppState>();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPasswordEnabled = prefs.getBool('isPasswordEnabled') ?? false;
      lockpass = prefs.getString('lockpass') ?? '';
      appState.isPasswordEnabled = _isPasswordEnabled;
      appState.lockpass = lockpass;
    });
  }

  Future<void> _saveState() async {
    final appState = context.read<MyAppState>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPasswordEnabled', _isPasswordEnabled);
    appState.isPasswordEnabled = _isPasswordEnabled;
    await prefs.setString('lockpass', lockpass);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: !appState.isDarkMode
                    ? [Colors.lightBlueAccent, Colors.blue]
                    : [Colors.black12, Colors.black45],
              )),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Version',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '1.0.0',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Row(
                    children: [
                      Text('Password',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),),
                      SizedBox(width: 23,),
                      TextButton.icon(
                        label: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            _isPasswordEnabled ? 'Enabled' : 'Disabled',
                            style: TextStyle(
                              color: _isPasswordEnabled ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.key, color: !appState.isDarkMode ? theme.colorScheme.inverseSurface : theme.colorScheme.primary,),
                        style: TextButton.styleFrom(
                          backgroundColor: appState.isDarkMode ? Colors.white : Colors.white54,
                          shadowColor: Colors.black,
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_isPasswordEnabled == false) {
                            showDialog(
                              context: context,
                              builder: (_) => _showLockPassword(),
                            ).then((value) {
                              // Refresh the state after closing the dialog
                              _loadState();
                            });
                          } else {
                            setState(() {
                              _isPasswordEnabled = false;
                              _saveState();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _showLockPassword() {
    return AlertDialog(
      title: Text(Texts.pass_lock),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Password',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextField(
            obscureText: !_isPasswordVisible,
            maxLength: 4,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm Password',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextField(
            obscureText: !_isPasswordVisible,
            maxLength: 4,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              setState(() {
                _confirmPassword = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_password == _confirmPassword) {
                setState(() {
                  _isPasswordEnabled = true;
                  _password = _confirmPassword;
                  lockpass = _password;
                });

                _saveState();

                final appState = context.read<MyAppState>();
                appState.isPasswordEnabled = true;
                appState.lockpass = _password;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password Lock Enabled!'),
                  ),
                );

                // Close the dialog after the password is submitted
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match!'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}