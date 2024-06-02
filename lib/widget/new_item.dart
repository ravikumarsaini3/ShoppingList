import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoping_list/data/Categories.dart';
import 'package:shoping_list/data/grossary_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  var issaving = false;

  var enterddata = '';
  var quantity = 1;
  var selectcategoary = categories[Categories.vegetables];
  final _formkey = GlobalKey<FormState>();
  void save2(BuildContext context) async {
    _formkey.currentState!.validate();
    _formkey.currentState!.save();
    issaving = true;

    final url = Uri.https(
        'shopinglist-71a0a-default-rtdb.firebaseio.com', 'shoping_list.json');

    final response = await http.post(url,
        headers: {'Content-Type': 'Application/json'},
        body: jsonEncode({
          'name': enterddata,
          'quantity': quantity,
          'category': selectcategoary!.title
        }));
    final Map<String, dynamic> loaddata = jsonDecode(response.body);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(GroceryItem(
        id: loaddata['name'],
        name: enterddata,
        quantity: quantity,
        category: selectcategoary!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Item ",
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return " name must be 1 to 50 character";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  enterddata = newValue!;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      //  initialValue: quantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == 1 ||
                            int.tryParse(value) == null) {
                          return " please Enter Correct Quantity Value";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        quantity = int.parse(newValue!);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: selectcategoary,
                        items: [
                          for (final categ in categories.entries)
                            DropdownMenuItem(
                                value: categ.value,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      color: categ.value.color,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(categ.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          selectcategoary = value;
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: issaving
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: issaving
                          ? null
                          : () {
                              save2(context);
                            },
                      child: issaving
                          ? Container(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              'Add',
                              style: TextStyle(),
                            ),
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
