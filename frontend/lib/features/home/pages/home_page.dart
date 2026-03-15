import 'package:flutter/material.dart';
// import 'package:frontend/features/history/widgets/transaction_card.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      body: SingleChildScrollView(
        // <--- This is the magic wrapper
        child: Column(
          // mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            balance(),
            Text('My accounts'),
            Column(
              children: [
                cardcard('Allkonto', '123 456 789', '15 000'),
                cardcard('Sparekonto1', '789 123 456', '127 000'),
                cardcard('Sparekonto2', '987 654 321', '67 000'),
              ],
            ),
            Text('All transactions'),
            transactionList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget balance() {
  return Container(
    margin: const EdgeInsets.all(32.0),
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Color(0xFF002D58),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Balance',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        // The main balance text
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '100 901,25 ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'NOK',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: balanceButton(
                Icons.north_east,
                'Transfer',
                Colors.white,
                Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: balanceButton(
                Icons.add_circle_outline,
                'Add Money',
                Colors.white.withOpacity(0.1),
                Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget balanceButton(
  IconData icon,
  String label,
  Color bgColor,
  Color textColor,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
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

Widget cardcard(String account, String accountNumber, String amount) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 185, 207, 228),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account,
              style: TextStyle(
                color: Color(0xFF002D58),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            // const SizedBox(height: 8),
            Text(accountNumber, style: TextStyle(color: Color(0xFF002D58))),
          ],
        ),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: Color(0xFF002D58),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(height: 2),
                Text('NOK', style: TextStyle(color: Color(0xFF002D58))),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right, // The arrow icon from your original image
              color: Colors.black26, // Light gray color like the design
            ),
          ],
        ),
      ],
    ),
  );
}

Widget transactionList() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 32.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        transactionItem("ICA Supermarket", "2026-02-22", "-450"),
        const Divider(
          height: 1,
          indent: 70,
        ), // Divider that starts after the icon
        transactionItem("Spotify Premium", "2026-02-22", "-119"),
        const Divider(height: 1, indent: 70),
        transactionItem("H&M Sweden", "2026-02-21", "-899"),
      ],
    ),
  );
}

Widget transactionItem(String name, String date, String amount) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        // The Red Circular Icon
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.north_east, color: Colors.red, size: 20),
        ),
        const SizedBox(width: 16),
        // Name and Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF002D58),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        // The Amount
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF002D58),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

// Widget transactionCard(String store, String date, String amount) {
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(15),
//       // Optional: Add a light shadow to make it pop like the screenshot
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 5),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         // 1. Circular Icon Background
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.red.withOpacity(0.1), // Light pink/red
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.north_east, // The "spending" arrow
//             color: Colors.red,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 16),

//         // 2. Store Name and Date
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 store,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Color(0xFF002D58),
//                 ),
//               ),
//               Text(
//                 date,
//                 style: const TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//             ],
//           ),
//         ),

//         // 3. Amount
//         Text(
//           amount,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Color(0xFF002D58),
//           ),
//         ),
//       ],
//     ),
//   );
// }
