import 'package:flutter/material.dart';
import 'package:myshoppinglist/widgets/grocery_list.dart';
import 'package:provider/provider.dart';
import 'theme/themeProvider.dart'; // Import the theme provider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Groceries App',
          theme: themeProvider.currentTheme,
          home: const GroceryList(),
        );
      },
    );
  }
}
