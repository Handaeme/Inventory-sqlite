import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _currencyFormat = NumberFormat('#,##0', 'id_ID');
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Header: Menampilkan Total Item
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Item: ${_items.length}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Icon(Icons.inventory, color: Colors.white, size: 28),
              ],
            ),
          ),
          // List Barang
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text('Belum ada barang',
                        style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(item.imagePath),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Stok: ${item.stock} | Harga: ${_currencyFormat.format(item.price)}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddItemScreen(item: item),
                              ),
                            ).then((_) => _loadItems()),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailScreen(item: item),
                            ),
                          ).then((_) => _loadItems()),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddItemScreen()),
        ).then((_) => _loadItems()),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 28),
        tooltip: 'Tambah Barang',
      ),
    );
  }
}
