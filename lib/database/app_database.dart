import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import '../models/hotel_model.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _db;

  AppDatabase._init();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB(Constants.dbName);
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgrade to version 2
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'client'
      )
    ''');

    await db.execute('''
      CREATE TABLE hotels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city TEXT NOT NULL,
        address TEXT,
        description TEXT,
        pricePerNight REAL NOT NULL,
        rating REAL NOT NULL,
        imageUrl TEXT,
        hasWifi INTEGER,
        hasParking INTEGER,
        hasPool INTEGER,
        hasRestaurant INTEGER,
        hasAC INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        hotelId INTEGER NOT NULL,
        checkIn TEXT NOT NULL,
        checkOut TEXT NOT NULL,
        guests INTEGER NOT NULL,
        rooms INTEGER NOT NULL,
        totalPrice REAL NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id),
        FOREIGN KEY(hotelId) REFERENCES hotels(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        hotelId INTEGER NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id),
        FOREIGN KEY(hotelId) REFERENCES hotels(id)
      )
    ''');

    await _insertInitialHotels(db);
    await _insertInitialAdmin(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ignore error if column already exists
      try {
        await db.execute("ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'client'");
      } catch (e) {
        // Column might exist
      }
      await _insertInitialAdmin(db);
    }
  }

  Future<void> _insertInitialAdmin(Database db) async {
    final maps = await db.query('users', where: 'email = ?', whereArgs: ['admin@booknest.com']);
    if (maps.isEmpty) {
      final admin = UserModel(
        fullName: 'Administrateur',
        email: 'admin@booknest.com',
        password: 'admin123',
        role: 'admin',
      );
      await db.insert('users', admin.toMap());
    }
  }

  Future<void> _insertInitialHotels(Database db) async {
    final maps = await db.query('hotels');
    if (maps.isNotEmpty) return; // Prevent duplicates if already seeded

    final initialHotels = [
      HotelModel(
        name: 'Hotel Marina Bay',
        city: 'Tanger',
        address: 'Avenue Mohammed VI, Tanger',
        description: 'Un magnifique hôtel offrant une vue imprenable sur la baie de Tanger.',
        pricePerNight: 750,
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        hasWifi: true, hasParking: true, hasPool: true, hasRestaurant: true, hasAC: true,
      ),
      HotelModel(
        name: 'Hotel Atlas View',
        city: 'Marrakech',
        address: 'Gueliz, Marrakech',
        description: 'Au coeur de la ville ocre, profitez du confort moderne avec un design traditionnel.',
        pricePerNight: 900,
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c0d589rx?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        hasWifi: true, hasParking: false, hasPool: true, hasRestaurant: true, hasAC: true,
      ),
      HotelModel(
        name: 'Blue Pearl Hotel',
        city: 'Chefchaouen',
        address: 'Medina, Chefchaouen',
        description: 'Séjournez dans la ville bleue dans un cadre apaisant et authentique.',
        pricePerNight: 500,
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        hasWifi: true, hasParking: false, hasPool: false, hasRestaurant: true, hasAC: true,
      ),
      HotelModel(
        name: 'Rabat Business Hotel',
        city: 'Rabat',
        address: 'Agdal, Rabat',
        description: 'Idéal pour vos voyages d\'affaires au centre de la capitale.',
        pricePerNight: 680,
        rating: 4.3,
        imageUrl: 'https://images.unsplash.com/photo-1542314831-c6a4203251a8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        hasWifi: true, hasParking: true, hasPool: false, hasRestaurant: true, hasAC: true,
      ),
      HotelModel(
        name: 'Agadir Beach Resort',
        city: 'Agadir',
        address: 'Secteur Touristique, Agadir',
        description: 'Un luxueux resort en bord de mer pour des vacances inoubliables.',
        pricePerNight: 1100,
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        hasWifi: true, hasParking: true, hasPool: true, hasRestaurant: true, hasAC: true,
      ),
    ];

    for (var hotel in initialHotels) {
      await db.insert('hotels', hotel.toMap());
    }
  }

  // --- Auth ---
  Future<int> registerUser(UserModel user) async {
    final database = await instance.db;
    return await database.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final database = await instance.db;
    final maps = await database.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final database = await instance.db;
    final maps = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final database = await instance.db;
    final maps = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // --- Hotels ---
  Future<int> insertHotel(HotelModel hotel) async {
    final database = await instance.db;
    return await database.insert('hotels', hotel.toMap());
  }

  Future<List<HotelModel>> getAllHotels() async {
    final database = await instance.db;
    final result = await database.query('hotels');
    return result.map((json) => HotelModel.fromMap(json)).toList();
  }

  Future<HotelModel?> getHotelById(int id) async {
    final database = await instance.db;
    final maps = await database.query(
      'hotels',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return HotelModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHotel(HotelModel hotel) async {
    final database = await instance.db;
    return await database.update(
      'hotels',
      hotel.toMap(),
      where: 'id = ?',
      whereArgs: [hotel.id],
    );
  }

  Future<int> deleteHotel(int id) async {
    final database = await instance.db;
    return await database.delete(
      'hotels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HotelModel>> searchHotels(String query) async {
    final database = await instance.db;
    final result = await database.query(
      'hotels',
      where: 'name LIKE ? OR city LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => HotelModel.fromMap(json)).toList();
  }

  Future<List<HotelModel>> filterHotels({double? maxPrice, double? minRating}) async {
    final database = await instance.db;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (maxPrice != null) {
      whereClause += 'pricePerNight <= ?';
      whereArgs.add(maxPrice);
    }
    
    if (minRating != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'rating >= ?';
      whereArgs.add(minRating);
    }

    final result = await database.query(
      'hotels',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return result.map((json) => HotelModel.fromMap(json)).toList();
  }

  // --- Bookings ---
  Future<int> insertBooking(BookingModel booking) async {
    final database = await instance.db;
    return await database.insert('bookings', booking.toMap());
  }

  Future<List<BookingModel>> getBookingsByUser(int userId) async {
    final database = await instance.db;
    final result = await database.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((json) => BookingModel.fromMap(json)).toList();
  }

  Future<List<BookingModel>> getBookingsWithHotelDetails(int userId) async {
    final database = await instance.db;
    final result = await database.rawQuery('''
      SELECT b.*, h.name as hotelName, h.city as hotelCity, h.imageUrl as hotelImage
      FROM bookings b
      JOIN hotels h ON b.hotelId = h.id
      WHERE b.userId = ?
      ORDER BY b.id DESC
    ''', [userId]);

    return result.map((json) {
      final hotel = HotelModel(
        id: json['hotelId'] as int,
        name: json['hotelName'] as String,
        city: json['hotelCity'] as String,
        address: '', description: '', pricePerNight: 0, rating: 0,
        imageUrl: json['hotelImage'] as String,
        hasWifi: false, hasParking: false, hasPool: false, hasRestaurant: false, hasAC: false
      );
      return BookingModel.fromMap(json, hotel: hotel);
    }).toList();
  }

  Future<int> cancelBooking(int bookingId) async {
    final database = await instance.db;
    return await database.update(
      'bookings',
      {'status': 'Cancelled'},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<int> deleteBooking(int bookingId) async {
    final database = await instance.db;
    return await database.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // --- Favorites ---
  Future<int> addFavorite(int userId, int hotelId) async {
    final database = await instance.db;
    return await database.insert('favorites', {
      'userId': userId,
      'hotelId': hotelId,
    });
  }

  Future<int> removeFavorite(int userId, int hotelId) async {
    final database = await instance.db;
    return await database.delete(
      'favorites',
      where: 'userId = ? AND hotelId = ?',
      whereArgs: [userId, hotelId],
    );
  }

  Future<List<HotelModel>> getFavoritesByUser(int userId) async {
    final database = await instance.db;
    final result = await database.rawQuery('''
      SELECT h.* 
      FROM hotels h
      JOIN favorites f ON h.id = f.hotelId
      WHERE f.userId = ?
    ''', [userId]);
    return result.map((json) => HotelModel.fromMap(json)).toList();
  }

  Future<bool> isFavorite(int userId, int hotelId) async {
    final database = await instance.db;
    final result = await database.query(
      'favorites',
      where: 'userId = ? AND hotelId = ?',
      whereArgs: [userId, hotelId],
    );
    return result.isNotEmpty;
  }

  // --- Dashboard ---
  Future<int> getTotalHotels() async {
    final database = await instance.db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM hotels');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalBookings() async {
    final database = await instance.db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalFavorites(int userId) async {
    final database = await instance.db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM favorites WHERE userId = ?', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalBookingAmount(int userId) async {
    final database = await instance.db;
    final result = await database.rawQuery(
      'SELECT SUM(totalPrice) as total FROM bookings WHERE userId = ? AND status != ?', 
      [userId, 'Cancelled']
    );
    if (result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
