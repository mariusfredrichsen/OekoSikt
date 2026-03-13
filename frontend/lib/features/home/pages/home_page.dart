import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   // @override
//   // State<HomePage> createState() => _HomePageState();
// }

class HomePage extends StatelessWidget {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      body: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [balance()],
      ),
    );
  }
}

Widget balance() {
  return Container(
    padding: const EdgeInsets.all(24.0),
    margin: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: const Color(0xFF002D58),
      borderRadius: BorderRadius.circular(30),
    ),

    child: Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        const Text(
          'Total Balance',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '100 901,20 ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'NOK',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Your Row of buttons would go here
      ],
    ),
  );

  // return Card(
  //   shape: ShapeBorder(
  //     // <-- Use RoundedRectangleBorder
  //     borderRadius: BorderRadius.circular(50.0), // <-- Set the border radius
  //   ),
  //   child: Container(
  //     padding: EdgeInsets.all(16),
  //     child: Text(
  //       'Product Name',
  //       style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //     ),
  //   ),
  // );

  // return Column(
  //   crossAxisAlignment: .center,
  //   children: [
  //     Container(
  //       margin: const EdgeInsets.all(10.0),
  //       color: Colors.amber[600],
  //       width: 100.0,
  //       height: 60.0,
  //       child: Text("Total balance"),
  //     ),
  //   ],
  // );
}

Widget balanceButton(
  IconData icon,
  String label,
  Color bgColor,
  Color textColor,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: bgColor == Colors.white
          ? null
          : Border.all(color: Colors.white24),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
