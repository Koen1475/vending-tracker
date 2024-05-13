import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grafiek
          Container(
            height: 200, // Hier kan de hoogte van de grafiek worden aangepast
            color: Colors.grey[300],
            child: Center(
              child: Text('Grafiek komt hier'),
            ),
          ),
          // Overzicht top 3 producten
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Top 3 Producten',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                // Hier komt de lijst met top 3 producten
                Text('Product 1'),
                Text('Product 2'),
                Text('Product 3'),
              ],
            ),
          ),
          // Lijst met producten
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Hier het aantal producten uit de vending machine
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Product ${index + 1}'),
                  onTap: () {
                    // Hier kan de functionaliteit worden toegevoegd om uitgaven bij te houden
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
