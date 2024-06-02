import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart ' as http;
import 'package:shoping_list/data/Categories.dart';

import 'package:shoping_list/data/grossary_item.dart';
import 'package:shoping_list/widget/new_item.dart';

class Shopinglist extends StatefulWidget {
  Shopinglist({super.key});

  @override
  State<Shopinglist> createState() => _ShopinglistState();
}

class _ShopinglistState extends State<Shopinglist> {
  var isloading = false;
  void showsnakbar(String title) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: const Duration(seconds: 2), content: Text(title)));
  }

  List<GroceryItem> grocerylist = [];
  @override
  void initState() {
    super.initState();
    _lodeddata();
  }

  String? _error;
  void _lodeddata() async {
    final url = Uri.https(
        'shopinglist-71a0a-default-rtdb.firebaseio.com', 'shoping_list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode > 400) {
        _error = "Failed to Finding the Item  plese try again later";
        setState(() {});
      }
      if (response.body == 'null') {
        isloading = true;
        setState(() {});
        return;
      }
      final Map<String, dynamic> listdata = jsonDecode(response.body);
      List<GroceryItem> templist = [];
      for (final item in listdata.entries) {
        final categoryy = categories.entries
            .firstWhere(
              (catitem) => catitem.value.title == item.value['category'],
            )
            .value;
        templist.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: categoryy),
        );
      }
      setState(() {
        grocerylist = templist;
        isloading = true;
      });
    } catch (e) {
      _error = "somthing went wrong  plese try again later";
      setState(() {});
    }
  }

  void additem(BuildContext context) async {
    final newitem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    grocerylist.add(newitem!);

    //_lodeddata();

    setState(() {
      showsnakbar('A new Item  Add successfully');
    });
  }

  void remove(GroceryItem item) async {
    var index = grocerylist.indexOf(item);
    setState(() {
      grocerylist.remove(item);
      showsnakbar('Remove successfully');
    });
    final url = Uri.https('shopinglist-71a0a-default-rtdb.firebaseio.com',
        'shoping_list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        grocerylist.insert(index, item);
        showsnakbar('cant not remove please try again later');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contant2 = ListView.builder(
      itemCount: grocerylist.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey(grocerylist[index].id),
          onDismissed: (direction) {
            remove(grocerylist[index]);
          },
          child: ListTile(
            title: Text(grocerylist[index].name),
            leading: Container(
              height: 20,
              width: 20,
              color: grocerylist[index].category.color,
            ),
            trailing: CircleAvatar(
                child: Text(grocerylist[index].quantity.toString())),
          ),
        );
      },
    );

    if (!isloading) {
      contant2 = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (grocerylist.isEmpty) {
      contant2 = Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
          child: Text(
            'ohh no nothing hare',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
          ),
        ),
        Center(
          child: Text(
            'Add somthing  ',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
          ),
        ),
      ]);
    }
    if (_error != null) {
      contant2 = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'SHOPING LIST',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                onPressed: () => additem(context),
                icon: const Icon(Icons.add),
              ),
            )
          ],
        ),
        body: contant2);
  }
}
