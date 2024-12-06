import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailMenuPage extends StatefulWidget {
  final String idMeal;

  const DetailMenuPage({super.key, required this.idMeal});

  @override
  _DetailMenuPageState createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  Map meal = {};

  @override
  void initState() {
    super.initState();
    fetchMealDetails();
  }

  Future<void> fetchMealDetails() async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.idMeal}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        meal = data['meals'][0];
      });
    } else {
      throw Exception('Gagal memuat detail menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['strMeal'] ?? 'Detail Menu'),
        backgroundColor: const Color.fromARGB(255, 97, 249, 254),
      ),
      body: meal.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(meal['strMealThumb']),
                    const SizedBox(height: 16),
                    Text(
                      meal['strMeal'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Category: ${meal['strCategory']}'),
                    Text('Area: ${meal['strArea']}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Instructions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(meal['strInstructions']),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    for (int i = 1; i <= 20; i++)
                      if (meal['strIngredient$i'] != null &&
                          meal['strIngredient$i'].isNotEmpty)
                        Text(
                            '${meal['strIngredient$i']} - ${meal['strMeasure$i']}'),
                  ],
                ),
              ),
            ),
      floatingActionButton: meal['strYoutube'] != null
          ? FloatingActionButton(
              onPressed: () => launchWebsite(meal['strYoutube']),
              child: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }

  void launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
