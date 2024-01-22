import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myshoppinglist/models/category.dart';
import 'package:myshoppinglist/widgets/new_item.dart';
import 'package:myshoppinglist/models/grocery_item.dart';
import 'package:provider/provider.dart';

import '../data/categories.dart';
import '../theme/themeProvider.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('flutter-myshoppinglist-default-rtdb.firebaseio.com',
        'flutter-myshoppinglist.json');
    print(url);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Use a null check before using the decoded data
        final data = json.decode(response.body);
        if (data == null) {
          setState(() {
            _groceryItems = [];
            _isLoading = false;
          });
        } else if (data is Map<String, dynamic>) {
          final Map<String, dynamic> listData = data;
          final List<GroceryItem> _loadedItems = [];
          listData.forEach((key, value) {
            if (value != null && value is Map<String, dynamic>) {
              final Category category = categories.entries
                  .firstWhere(
                      (catItem) => catItem.value.title == value['category'],
                      orElse: () => categories.entries.first)
                  .value;
              _loadedItems.add(
                GroceryItem(
                  id: key,
                  name: value['name'],
                  quantity: value['quantity'],
                  category: category,
                ),
              );
            }
          });
          setState(() {
            _groceryItems = _loadedItems;
            _isLoading = false;
          });
        } else {
          throw Exception('Data is not in expected format.');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    // The missing method definition
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-myshoppinglist-default-rtdb.firebaseio.com',
        'lutter-myshoppinglist.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              ThemeProvider themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              switch (value) {
                case 'Dark':
                  themeProvider.switchTheme(ThemeData.dark());
                  break;
                case 'Light':
                  themeProvider.switchTheme(ThemeData.light());
                  break;
                case 'Pink':
                  themeProvider
                      .switchTheme(ThemeData(primarySwatch: Colors.pink));
                  break;
                case 'Blue':
                  themeProvider
                      .switchTheme(ThemeData(primarySwatch: Colors.blue));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'Dark', child: Text('Dark')),
              const PopupMenuItem<String>(value: 'Light', child: Text('Light')),
              const PopupMenuItem<String>(value: 'Pink', child: Text('Pink')),
              const PopupMenuItem<String>(value: 'Blue', child: Text('Blue')),
            ],
          ),
        ],
      ),
      body: content,
    );
  }
}
