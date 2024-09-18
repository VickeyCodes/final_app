import 'package:flutter/material.dart';
import 'crypto_service.dart';
import 'crypto_detail_screen.dart';
import 'crypto_model.dart';

void main() {
  runApp(CryptoApp());
}

class CryptoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cointos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1e1e1e),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Crypto> _favorites = [];
  List<Crypto> _watchlist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CryptoListScreen(
            onAddFavorite: _addToFavorites,
            onAddWatchlist: _addToWatchlist,
          ),
          FavoritesScreen(favorites: _favorites),
          WatchlistScreen(watchlist: _watchlist),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Cryptos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }

  void _addToFavorites(Crypto crypto) {
    setState(() {
      if (!_favorites.contains(crypto)) {
        _favorites.add(crypto);
      }
    });
  }

  void _addToWatchlist(Crypto crypto) {
    setState(() {
      if (!_watchlist.contains(crypto)) {
        _watchlist.add(crypto);
      }
    });
  }
}

class CryptoListScreen extends StatefulWidget {
  final Function(Crypto) onAddFavorite;
  final Function(Crypto) onAddWatchlist;

  CryptoListScreen({
    required this.onAddFavorite,
    required this.onAddWatchlist,
  });

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late Future<List<Crypto>> _cryptoList;
  List<Crypto> _filteredCryptos = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCryptos();
  }

  Future<void> _fetchCryptos() async {
    _cryptoList = CryptoService().fetchCryptos();
    final cryptos = await _cryptoList;
    setState(() {
      _filteredCryptos = cryptos;
    });
  }

  void _filterCryptos(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredCryptos = [];
      } else {
        _filteredCryptos = _filteredCryptos
            .where((crypto) =>
                crypto.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Cointos',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    onChanged: _filterCryptos,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: FutureBuilder<List<Crypto>>(
                future: _cryptoList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No data available',
                            style: TextStyle(color: Colors.white)));
                  } else {
                    final List<Crypto> displayedCryptos = _searchQuery.isEmpty
                        ? snapshot.data!
                        : _filteredCryptos;

                    return RefreshIndicator(
                      onRefresh: _fetchCryptos,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: displayedCryptos.length,
                        itemBuilder: (context, index) {
                          final crypto = displayedCryptos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Image.network(
                                crypto.image,
                                width: 50,
                                height: 50,
                              ),
                              title: Text(crypto.name,
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text(
                                'Price: \$${crypto.currentPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              tileColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CryptoDetailScreen(crypto: crypto),
                                  ),
                                );
                              },
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  if (value == 'favorite') {
                                    widget.onAddFavorite(crypto);
                                  } else if (value == 'watchlist') {
                                    widget.onAddWatchlist(crypto);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'favorite',
                                    child: Text('Add to Favorites'),
                                  ),
                                  PopupMenuItem(
                                    value: 'watchlist',
                                    child: Text('Add to Watchlist'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Crypto> favorites;

  FavoritesScreen({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final crypto = favorites[index];
          return ListTile(
            leading: Image.network(
              crypto.image,
              width: 50,
              height: 50,
            ),
            title: Text(crypto.name, style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Price: \$${crypto.currentPrice?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}

class WatchlistScreen extends StatelessWidget {
  final List<Crypto> watchlist;

  WatchlistScreen({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final crypto = watchlist[index];
          return ListTile(
            leading: Image.network(
              crypto.image,
              width: 50,
              height: 50,
            ),
            title: Text(crypto.name, style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Price: \$${crypto.currentPrice?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
