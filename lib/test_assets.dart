import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestAssetsPage extends StatelessWidget {
  final List<String> testImages = [
    'assets/images/Angraecum.jpg',
    'assets/images/Brassavola.jpg',
    'assets/images/Cattleya.jpg',
    'assets/images/Epidendrum.jpg',
    'assets/images/Lycaste.jpg',
    'assets/images/Masdevallia.jpg',
    'assets/images/Paphiopedilum.jpg',
    'assets/images/Phalaenopsis.jpg',
    'assets/images/Vanda.jpg',
    'assets/images/Zygopetalum.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Assets'),
      ),
      body: ListView.builder(
        itemCount: testImages.length,
        itemBuilder: (context, index) {
          final imagePath = testImages[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  imagePath,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 150,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('ERROR loading $imagePath: $error');
                      return Container(
                        color: Colors.red[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              Text('FAILED TO LOAD'),
                              Text(imagePath, style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
