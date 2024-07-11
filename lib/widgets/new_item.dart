import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';


class NewItem extends StatefulWidget{
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>(); 
  // a key (global key value) to access the form widget and set the validation up
  // allowing the form to keep its internal state
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  var _isSending = false;

  void _saveItem() async {
    // trigger validation
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      // debug
      // print('Name: $_enteredName');
      // print('Quantity: $_enteredQuantity');
      // print('Category: ${_selectedCategory.title}');
      
      final url = Uri.https('flutter-prep-225f8-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list.json');

      // TODO: add exception handling
      final response = await http.post(url,
                headers: {
                  'Content-Type' : 'application/json'
                  },
                body: json.encode({
                    'name': _enteredName,
                    'quantity': _enteredQuantity,
                    'category': _selectedCategory.title,
                    },
                  ),
                );
      // debug
      // print(response.body);
      // print(response.statusCode);
      
      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GroceryItem(
        id: resData['name'], 
        name: _enteredName, 
        quantity: _enteredQuantity, 
        category: _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          // the Form widgets contains a lot of useful features
          // to manage user input (witch can be done without it)
          // such as: validation, show validation errors, etc.
          child: Column(
            children: [
              TextFormField( // a text input field specifit to Form insearch of a TextField
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  ),
                validator: (value) { 
                  // a validation function that returns an error message if the input is invalid
                  // or null if the input is valid
                  // you can decide when Flutter will call this function
                  if (value == null || 
                      value.isEmpty || 
                      value.trim().length <= 1 || 
                      value.trim().length > 50) 
                  {
                    return 'Must be between 1 and 50 characters long.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                        ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) { 
                        if (value == null || 
                            value.isEmpty || 
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0 )
                        {
                          return 'Must be a valid positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child:
                    DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [ // we create the list with a for loop
                        for (final category in categories.entries) // entries returns a list of key-value pairs
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(width: 6),
                              Text(category.value.title),
                              ],
                            ),
                          ),
                      ], 
                      onChanged: (value) {
                        // this function is called when the user selects a category
                        // you can use this to update the state of the widget
                        // and save the value in the state (no need to call onSaved)
                        setState(() { // required because the visible value
                                      // of the selected category must be shown
                                      // in the widget, so the Form must be rebuilt
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending 
                    ? null  // disable the button while sending 
                    : () { 
                      _formKey.currentState!.reset();
                    }, 
                    child: const Text('Reset'),
                    ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem, 
                    child: _isSending 
                    ? const SizedBox(
                      height: 16, 
                      width: 16, 
                      child: CircularProgressIndicator(),
                      ) 
                    : const Text('Add Item'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}