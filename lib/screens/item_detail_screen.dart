import 'package:flutter/material.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  ItemDetailScreen({required this.item});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ItemTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// Memuat transaksi dari database
  void _loadTransactions() async {
    final transactions = await _dbHelper.getTransactions(widget.item.id!);
    setState(() {
      _transactions = transactions;
    });
  }

  /// Menghapus item dari database
  void _deleteItem() async {
    await _dbHelper.deleteItem(widget.item.id!);
    Navigator.pop(context); // Kembali ke layar sebelumnya setelah menghapus
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Konfirmasi Hapus'),
                content: Text('Apakah Anda yakin ingin menghapus item ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      _deleteItem();
                      Navigator.pop(context);
                    },
                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Detail Item
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text(
                          widget.item.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Deskripsi: ${widget.item.description}'),
                    Text('Kategori: ${widget.item.category}'),
                    Text('Harga: Rp ${widget.item.price}'),
                    Text('Stok: ${widget.item.stock}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            // Tombol Tambah Transaksi
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionScreen(item: widget.item),
                    ),
                  ).then((_) {
                    _loadTransactions();
                  });
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Tambah Riwayat Transaksi',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),

            // Riwayat Transaksi
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _transactions.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat transaksi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              transaction.type == 'Masuk'
                                  ? Icons.download
                                  : Icons.upload,
                              color: transaction.type == 'Masuk'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              '${transaction.type} - ${transaction.quantity}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Tanggal: ${transaction.date}'),
                            trailing: Text(
                              'ID: ${transaction.id}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
