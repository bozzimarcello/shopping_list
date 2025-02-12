import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems= [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    
    final url = Uri.https(
      'flutter-prep-225f8-default-rtdb.europe-west1.firebasedatabase.app', 
      'shopping-list.json');

    try {

      final response = await http.get(url);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'An error occurred: ${response.statusCode}';
        });
      }

      if (response.body == 'null') { // the actual value depends on the backend
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final Map<String,dynamic> listData = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries.firstWhere(
          (element) => element.value.title == item.value['category']
          ).value;
        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
        setState(() {
          // debug _error = 'An exception was raised: ${error.toString()}';
          _error = 'Something went wrong! Please try again.';
        });
    }

  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem(), 
      // see the lesson about the Navigator widget for more information
      // there's a navigation section in the course
      ),
    );
    
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);

    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final url = Uri.https(
      'flutter-prep-225f8-default-rtdb.europe-west1.firebasedatabase.app', 
      'shopping-list/${groceryItem.id}.json'); // to target the specific item
    
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // show a snackbar with an error message
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
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
              '${_groceryItems[index].quantity}x'
              ),
          ),
        )
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar:AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
  
}