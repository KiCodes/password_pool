
//Singleton
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseService{

  static final DataBaseService _dataBaseService = DataBaseService._internal();

  factory DataBaseService() => _dataBaseService;
  DataBaseService._internal();


  static Database? _database;

  Future<Database> get database async {
    //checking if db is null
    if(_database != null){
      return _database!;
    }
    //if does not exist create
    _database = await initDatabase();
    return _database!;
  }
  Future<Database> initDatabase()async{
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = getDirectory.path + '/users.dh';
    print("path $path");
    log(path);
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database database, int version)async{
    await database.execute(
      "CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, email TEXT, age INTEGER"
    );
    log("TABLE Created ${database.path}");
  }

}