import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:just_audio/just_audio.dart';

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

List<Product> products = [
  Product('Kinder Bueno', 'assets/images/bueno.png', 1.60),
  Product('Kinder Bueno Wit', 'assets/images/bueno_wit.png', 1.60),
  Product('Snicker', 'assets/images/snicker.png', 1.60),
  Product('Mars', 'assets/images/mars.png', 1.60),
  Product('Bounty', 'assets/images/bounty.png', 1.60),
  Product('Twix', 'assets/images/twix.png', 1.60),
  Product('KitKat', 'assets/images/kitkat.png', 1.60),
  Product('KitKat Chunky', 'assets/images/chunky.png', 1.60),
  Product('Balisto', 'assets/images/balisto.png', 1.60),
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AudioPlayer _player;
  Map<String, int> productCount = {};
  double totalExpense = 0.0;
  double limit = 0.0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 15, 17, 100),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '💸 Totale uitgaven: \€${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            child: charts.BarChart(
              _createSampleData(),
              animate: true,
              barRendererDecorator: charts.BarLabelDecorator<String>(
                labelPosition: charts.BarLabelPosition.inside,
                insideLabelStyleSpec: const charts.TextStyleSpec(
                  color: charts.MaterialPalette.white,
                ),
              ),
              domainAxis: const charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(
                  labelStyle:
                      charts.TextStyleSpec(color: charts.MaterialPalette.white),
                ),
              ),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    color: charts.MaterialPalette.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(55, 141, 255, 1),
                    borderRadius: BorderRadius.circular(10.0),
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
                      for (final entry in getProductCounts().take(3))
                        Text(
                          '🔼 ${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: const Color.fromRGBO(25, 29, 35, 1),
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '\€${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 255, 123)),
                            ),
                            if (productCount[product.name] != null &&
                                productCount[product.name]! > 0)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: Colors.white,
                                  onPressed: () => removeProduct(product.name),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSettingsDialog(context),
        child: const Icon(Icons.settings),
      ),
    );
  }

  void addProduct(Product product) {
    setState(() {
      productCount[product.name] = (productCount[product.name] ?? 0) + 1;
      calculateTotalExpense();
      checkLimit();
    });
  }

  void removeProduct(String productName) {
    setState(() {
      if (productCount[productName] != null && productCount[productName]! > 0) {
        productCount[productName] = productCount[productName]! - 1;
        calculateTotalExpense();
        checkLimit();
      }
    });
  }

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

    for (final entry in productCount.entries) {
      final product = products.firstWhere((p) => p.name == entry.key);
      final totalExpense = entry.value * product.price;
      final now = DateTime.now();
      final day = '${now.year}-${now.month}-${now.day}';

      dailyExpenses.update(day, (value) => value + totalExpense,
          ifAbsent: () => totalExpense);
    }

    return dailyExpenses.entries
        .map((entry) => DailyExpense(entry.key, entry.value))
        .toList();
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    TextEditingController _limitController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limiet instellen'),
          content: TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Voer limiet in"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Opslaan'),
              onPressed: () {
                if (_limitController.text.isNotEmpty) {
                  setState(() {
                    limit = double.parse(_limitController.text);
                  });
                  Navigator.of(context).pop();
                  checkLimit();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void checkLimit() {
    if (totalExpense > limit) {
      playAlertSound();
    }
  }

  playAlertSound() async {
    try {
      await _player.setAsset("alert_sound.mp3");
      await _player.play();
    } catch (e) {
      print("Fout bij afspelen van audio: $e");
    }
  }
}

class DailyExpense {
  final String day;
  final double totalExpense;

  DailyExpense(this.day, this.totalExpense);
}
