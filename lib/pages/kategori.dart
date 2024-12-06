import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import '../auth/login.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  String _username = '';
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('current_user') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = data['categories'];
      });
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat Datang! $_username'),
        backgroundColor: const Color.fromARGB(255, 97, 249, 254),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(category['strCategoryThumb']),
                    title: Text(category['strCategory']),
                    subtitle: Text(category['strCategoryDescription']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MenuPage(category: category['strCategory']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
