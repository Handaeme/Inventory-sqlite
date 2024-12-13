import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatelessWidget {
  final Item item;
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _type = 'Masuk';
  int _quantity = 0;

  AddTransactionScreen({required this.item});

  void _saveTransaction(BuildContext context) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final transaction = ItemTransaction(
      itemId: item.id!,
      type: _type,
      quantity: _quantity,
      date: date,
    );

    await _dbHelper.insertTransaction(transaction);
    final newStock =
        _type == 'Masuk' ? item.stock + _quantity : item.stock - _quantity;
    await _dbHelper.updateItemStock(item.id!, newStock);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Riwayat',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown Jenis Transaksi
                  Text(
                    'Jenis Transaksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: ['Masuk', 'Keluar']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                      type == 'Masuk'
                                          ? Icons.download
                                          : Icons.upload,
                                      color: Colors.blueAccent),
                                  SizedBox(width: 10),
                                  Text(type),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => _type = value!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Input Jumlah
                  Text(
                    'Jumlah Barang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.numbers, color: Colors.blueAccent),
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Masukkan jumlah yang valid';
                      }
                      return null;
                    },
                    onSaved: (value) => _quantity = int.parse(value!),
                  ),

                  SizedBox(height: 20),

                  // Tombol Simpan
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _saveTransaction(context);
                        }
                      },
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Simpan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
