import 'package:flutter/material.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}