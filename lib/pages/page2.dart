import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeSeasonsPage extends StatefulWidget {
  final Map<String, dynamic> anime;

  const AnimeSeasonsPage({super.key, required this.anime});

  @override
  State<AnimeSeasonsPage> createState() => _AnimeSeasonsPageState();
}

class _AnimeSeasonsPageState extends State<AnimeSeasonsPage> {
  Map<int, List<Map<String, dynamic>>> episodesBySeason = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    final animeTitle = widget.anime['title'];
    final snapshot = await FirebaseFirestore.instance
        .collection('Animes')
        .doc(animeTitle)
        .collection('Episodes')
        .get();

    final allEpisodes = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    final grouped = <int, List<Map<String, dynamic>>>{};
    for (var episode in allEpisodes) {
      final season = episode['season'];
      grouped.putIfAbsent(season, () => []).add(episode);
    }

    setState(() {
      episodesBySeason = grouped;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.anime['title'],
          style: const TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: (episodesBySeason.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
            .map((entry) {
          final season = entry.key;
          final episodes = entry.value
            ..sort((a, b) => a['episode'].compareTo(b['episode']));

          return ExpansionTile(
            title: Row(
              children: [
                Image.asset(
                  widget.anime['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Text(
                  'Season $season',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            children: episodes.map((ep) {
              return ListTile(
                title: Text(
                  ep['title'],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
