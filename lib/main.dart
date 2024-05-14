import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vending Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(13, 15, 17, 100),
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

//Producten lijst
List<Product> products = [
  Product('Kinder Bueno', 'assets/images/bueno.png', 1.60),
  Product('Kinder Bueno Wit', 'assets/images/bueno_wit.png', 1.60),
  Product('Snicker', 'assets/images/snicker.png', 1.60),
  Product('Mars', 'assets/images/mars.png', 1.60),
  Product('Bounty', 'assets/images/twix.png', 1.60),
  Product('Twix', 'assets/images/twix.png', 1.60),
  Product('KitKat', 'assets/images/twix.png', 1.60),

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
        // title: const Text(
        //   'Vending Tracker',
        //   style: TextStyle(
        //     color: Colors.white,
        //   ),
        // ),
        backgroundColor: const Color.fromRGBO(13, 15, 17, 100),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Totaal uitgaven
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '💸 Totaal uitgaven: \€${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Grafiek
          Container(
            height: 200, // Hoogte van de grafiek
            padding: const EdgeInsets.all(16.0),
            child: charts.BarChart(
              _createSampleData(), // Functie om de grafiekgegevens te maken
              animate: true, // Animatie toevoegen aan de grafiek (optioneel)
              // Voeg een aangepaste decorator toe om de stijl van de labels te wijzigen
              barRendererDecorator: charts.BarLabelDecorator<String>(
                labelPosition: charts.BarLabelPosition.inside,
                insideLabelStyleSpec: const charts.TextStyleSpec(
                  color: charts.MaterialPalette.white, // Tekstkleur wit maken
                ),
              ),
              domainAxis: const charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                labelStyle:
                    charts.TextStyleSpec(color: charts.MaterialPalette.white),
              )),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    color: charts.MaterialPalette.white, // Tekstkleur wit maken
                  ),
                ),
              ),
            ),
          ),

          // Overzicht top 3 producten
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(55, 141, 255,
                        1), // Correcte kleurinstelling met alfa-waarde
                    borderRadius: BorderRadius.circular(
                        10.0), // Kies de gewenste waarde voor de afgeronde hoeken
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '📊 Top 3 Producten',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Hier komt de lijst met top 3 producten
                      for (final entry in getProductCounts().take(3))
                        Text(
                          '🔼 ${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ), // Tekstkleur wit
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lijst met producten

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Padding aan de zijkanten van de lijst
              child: ListView.builder(
                itemCount: products.length, // Aantal producten
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0), // Marge tussen elke product "box"
                    child: Card(
                      // Voeg een kaart toe om de vakken voor de producten te scheiden
                      color: const Color.fromRGBO(
                          25, 29, 35, 1), // Achtergrondkleur van het hele vak
                      child: ListTile(
                        leading: Image.asset(
                          product.imagePath,
                          width: 60,
                          height: 60,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  color: Colors.white), // Tekstkleur wit
                            ),
                            Text(
                              '\€${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color.fromARGB(
                                      255, 0, 255, 123)), // Tekstkleur wit
                            ),
                            if (productCount[product.name] != null &&
                                productCount[product.name]! > 0)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red, // Rode achtergrondkleur
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Ronde hoeken
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: Colors.white, // Icon kleur wit
                                  onPressed: () => removeProduct(product.name),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          // Functie om het product toe te voegen
                          addProduct(product);
                        },
                      ),
                    ),
                  );
                },
              ),
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
        // Pas de kleur van de staafjes aan naar rood
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DailyExpense expense, _) => expense.day,
        measureFn: (DailyExpense expense, _) => expense.totalExpense,
        data: data,
        // Voeg een aangepast domein renderer toe om afgeronde randen toe te passen
        // De grootte van de afgeronde hoeken
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
