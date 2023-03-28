
//Singleton
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'PasswordModel.dart';

class DatabaseService{

  static final DatabaseService _dataBaseService = DatabaseService._internal();

  factory DatabaseService() => _dataBaseService;
  DatabaseService._internal();


  static Database? _database;

  Future<Database> get database async {
    //checking if db is null
    if(_database != null){
      return _database!;
    }
    //if does not exist create
    _database = await initDatabase();
    print("no db trying to create");
    return _database!;
  }
  Future<Database> initDatabase()async{
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = getDirectory.path + '/users.dh';
    // print("path $path");
    // log(path);
    try {
      final database = await openDatabase(path, onCreate: _onCreate, version: 2);
      // await deleteDatabase(path);
      return database;
    } catch (e) {
      print("Error creating database: $e");
      log("Error creating database: $e");
      rethrow;
    }
  }

  void _onCreate(Database database, int version) async {
    await database.execute(
            "CREATE TABLE Passwords(id INTEGER PRIMARY KEY AUTOINCREMENT, field TEXT, password TEXT)");
    log("Table Created");
    print("table created ${database.path}");
  }

  Future<int> insertPasswordField(PasswordModel password) async {
    final db = await database;
    return db.insert('Passwords', password.toMap());
  }


  Future<void> editPasswordField(PasswordModel passwordModel)async{
    final db = await _dataBaseService.database;
    var Updated = await db.update("Passwords", passwordModel.toMap(), where: 'id=?', whereArgs: [passwordModel.id]);
    log(Updated.toString());
    print("Updated  $Updated");

  }
  Future<void> deletePasswordField(int id)async{
    final db = await _dataBaseService.database;
    var deleted = await db.delete("Passwords", where: 'id=?', whereArgs: [id]);
    log(deleted.toString());
    print("deleted  $deleted");
  }

  Future<void> deleteAllField()async{
    final db = await _dataBaseService.database;
    var deleted = await db.execute("DELETE FROM Passwords;");

    print("deleted");
  }

  Future<PasswordModel?> getPasswordById(int id) async {
    final db = await database;
    final result = await db.query("Passwords",
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isNotEmpty) {
      return PasswordModel.fromMap(result.first);
    } else {
      return null;
    }
  }


  Future<List<PasswordModel>> getAllPasswords()async{
    final db = await _dataBaseService.database;
    var data = await db.query("Passwords");
    List<PasswordModel> passwords = List.generate(data.length, (index) => PasswordModel.fromJson(data[index]));
    print(passwords.length);
    print('Printing all passwords:');

    for (var password in passwords) {
      print(password.password);
    }
    return passwords;

  }
}