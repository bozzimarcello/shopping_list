import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class NewItem extends StatefulWidget{
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          // the Form widgets contains a lot of useful features
          // to manage user input (witch can be done without it)
          // such as: validation, show validation errors, etc.
          child: Column(
            children: [
              TextFormField( // a text input field specifit to Form insearch of a TextField
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) { 
                  // a validation function that returns an error message if the input is invalid
                  // or null if the input is valid
                  // you can decide when Flutter will call this function
                  return 'demo error message';
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
                      initialValue: '1',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child:
                    DropdownButtonFormField(
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
                      },
                    ),
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