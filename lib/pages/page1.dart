import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'page2.dart';
import 'package:app375/pages/Login.dart';
 // <-- make sure this import path is correct

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredAnime = [];
  List<Map<String, dynamic>> _animeList = [];

  @override
  void initState() {
    super.initState();
    fetchAnimeList().then((animeList) {
      setState(() {
        _animeList = animeList;
        _filteredAnime = animeList;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchAnimeList() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('Animes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['title'] = doc.id;
      data['favorite'] = data['favorite'] ?? false;
      return data;
    }).toList();
  }

  void _filterAnime(String query) {
    setState(() {
      _filteredAnime = _animeList
          .where((anime) =>
          anime['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      _filteredAnime[index]['favorite'] = !_filteredAnime[index]['favorite'];
    });

    final animeTitle = _filteredAnime[index]['title'];
    FirebaseFirestore.instance
        .collection('Animes')
        .doc(animeTitle)
        .update({'favorite': _filteredAnime[index]['favorite']});
  }

  void _navigateToAnimeDetail(BuildContext context, Map<String, dynamic> anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeSeasonsPage(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("BTAnime", style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Login"),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "BTAnime",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for anime...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              onChanged: _filterAnime,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAnime.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: Image.asset(
                        _filteredAnime[index]['image']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        _filteredAnime[index]['title']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _filteredAnime[index]['favorite'] == true
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.yellow,
                        ),
                        onPressed: () => _toggleFavorite(index),
                      ),
                      onTap: () => _navigateToAnimeDetail(
                          context, _filteredAnime[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
