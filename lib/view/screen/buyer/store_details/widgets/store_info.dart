import 'package:flutter/material.dart';

class StoreInfo extends StatelessWidget {
  const StoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [

        SizedBox(height: 35),

        Text(
          "Tech Store",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.star,
                color: Colors.amber,
                size: 18),

            SizedBox(width: 4),

            Text("4.8"),

            SizedBox(width: 20),

            Icon(Icons.location_on,
                size: 18,
                color: Colors.red),

            SizedBox(width: 4),

            Text("2.1 km"),

            SizedBox(width: 20),

            Icon(Icons.inventory_2,
                size: 18),

            SizedBox(width: 4),

            Text("250 Products"),
          ],
        ),
      ],
    );
  }
}