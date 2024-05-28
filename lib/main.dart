import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/Gif.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Gif>> _gifList;

  Future<List<Gif>> _getGifs() async {
    final response = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/trending?api_key=nzCYKjzh2PQ2EhJH5rdo98dbtWNiKHMb&limit=10&offset=0&rating=g&bundle=messaging_non_clips"));

    if (response.statusCode == 200) {
      List<Gif> gifs = [];
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        gifs.add(Gif(item["title"], item["images"]["original"]["url"]));
      }

      return gifs;
    } else {
      throw Exception("Failed to load gifs");
    }
  }

  @override
  void initState() {
    super.initState();
    _gifList = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API-REST Consumer',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Giphy API', style: TextStyle(color: Colors.white)),
        ),
        body: FutureBuilder(
          future: _gifList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                crossAxisCount: 2,
                children: _listGifs(snapshot.data),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("Error");
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  List<Widget> _listGifs(List<Gif>? data) {
    List<Widget> gifs = [];
    if (data != null) {
      for (var gif in data) {
        gifs.add(
          GifCard(gif: gif),
        );
      }
    }
    return gifs;
  }
}

class GifCard extends StatelessWidget {
  const GifCard({
    Key? key,
    required this.gif,
  }) : super(key: key);

  final Gif gif;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(child: Image.network(gif.url, fit: BoxFit.fill)),
        ],
      ),
    );
  }
}
