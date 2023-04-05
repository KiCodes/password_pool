import 'package:flutter/material.dart';
import 'package:password_pool/PasswordModel.dart';
import 'database_service.dart';
import 'main.dart';

final _databaseService = DatabaseService();

class EditPasswordPage extends StatefulWidget {
  final PasswordModel password;
  final DatabaseService databaseService;
  final Function updatePasswords;

  EditPasswordPage({
    required this.password,
    required this.databaseService,
    required this.updatePasswords,
  });

  @override
  _EditPasswordPageState createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _field;
  late String _password;

  late AnimationController _animationController;
  late Animation<double> _animation;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _field = widget.password.field;
    _password = widget.password.password;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.forward();
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final updatedPassword = widget.password.copyWith(
        field: _field,
        password: _password,
      );
      await widget.databaseService.editPasswordField(updatedPassword);
      final db_passwords = await widget.databaseService.getAllPasswords();
      widget.updatePasswords(db_passwords);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Being Used By',
                  style: TextStyle(
                      color: theme.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  initialValue: widget.password.field,
                  maxLength: 15,
                  style: TextStyle(
                      color: theme.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 3),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 3),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _field = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text('Password',
                    style: TextStyle(
                        color: theme.primary,
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  initialValue: widget.password.password,
                  maxLength: 25,
                  style: TextStyle(
                      color: theme.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 3),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 3),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updatePassword,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
