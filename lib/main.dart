import 'package:flutter/material.dart';
import 'package:shoping_list/grossary_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 147, 229, 250),
              brightness: Brightness.dark,
              surface: Color.fromARGB(250, 40, 24, 11)),
          scaffoldBackgroundColor: Color.fromARGB(255, 43, 24, 12),
        ),
        home: Shopinglist());
  }
}
