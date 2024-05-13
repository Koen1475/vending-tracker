import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

class Product {
  final String name;
  final String imagePath;
  final double price;

  Product(this.name, this.imagePath, this.price);
}

List<Product> products = [
  Product('Kinder Bueno', 'assets/images/bueno.png', 1.0),
  Product('Kinder Bueno wit', 'assets/images/bueno_wit.png', 1.5),
  // Voeg hier andere producten toe op dezelfde manier
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> productCount = {};
  double totalExpense = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Totaal uitgaven
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Totaal uitgaven: \$${totalExpense.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Grafiek
          Container(
            height: 200, // Hoogte van de grafiek
            padding: EdgeInsets.all(16.0),
            child: charts.BarChart(
              _createSampleData(), // Functie om de grafiekgegevens te maken
              animate: true, // Animatie toevoegen aan de grafiek (optioneel)
            ),
          ),

          // Overzicht top 3 producten
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Top 3 Producten',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Hier komt de lijst met top 3 producten
                for (final entry in getProductCounts().take(3))
                  Text('${entry.key}: ${entry.value}'),
              ],
            ),
          ),
          // Lijst met producten
          Expanded(
            child: ListView.builder(
              itemCount: products.length, // Aantal producten
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Image.asset(
                    product.imagePath,
                    width: 40,
                    height: 40,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name),
                      Text('\$${product.price.toStringAsFixed(2)}'),
                      if (productCount[product.name] != null &&
                          productCount[product.name]! > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[200], // Lichtgrijze achtergrondkleur
                            borderRadius:
                                BorderRadius.circular(10.0), // Ronde hoeken
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => removeProduct(product.name),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Functie om het product toe te voegen
                    addProduct(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void addProduct(Product product) {
    setState(() {
      productCount[product.name] = (productCount[product.name] ?? 0) + 1;
      calculateTotalExpense();
    });
  }

  void removeProduct(String productName) {
    setState(() {
      if (productCount[productName] != null && productCount[productName]! > 0) {
        productCount[productName] = productCount[productName]! - 1;
        calculateTotalExpense();
      }
    });
  }

  // Functie om de totale uitgaven te berekenen
  void calculateTotalExpense() {
    double total = 0.0;
    for (final entry in productCount.entries) {
      final product = products.firstWhere((p) => p.name == entry.key);
      total += entry.value * product.price;
    }
    setState(() {
      totalExpense = total;
    });
  }

  Iterable<MapEntry<String, int>> getProductCounts() {
    return productCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<charts.Series<DailyExpense, String>> _createSampleData() {
    final data = generateDailyExpenses();

    return [
      charts.Series<DailyExpense, String>(
        id: 'Expense',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DailyExpense expense, _) => expense.day,
        measureFn: (DailyExpense expense, _) => expense.totalExpense,
        data: data,
      )
    ];
  }

  List<DailyExpense> generateDailyExpenses() {
    Map<String, double> dailyExpenses = {};

    // Loop over alle producten en tel de totale uitgaven per dag op
    for (final entry in productCount.entries) {
      final product = products.firstWhere((p) => p.name == entry.key);
      final totalExpense = entry.value * product.price;
      final now = DateTime.now();
      final day =
          '${now.year}-${now.month}-${now.day}'; // Gebruik de huidige dag als voorbeeld

      dailyExpenses.update(day, (value) => value + totalExpense,
          ifAbsent: () => totalExpense);
    }

    // Converteer de Map naar een lijst van DailyExpense objecten
    return dailyExpenses.entries
        .map((entry) => DailyExpense(entry.key, entry.value))
        .toList();
  }
}

// Klasse om de dagelijkse uitgaven te vertegenwoordigen
class DailyExpense {
  final String day;
  final double totalExpense;

  DailyExpense(this.day, this.totalExpense);
}
