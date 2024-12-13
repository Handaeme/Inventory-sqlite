import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;

  AddItemScreen({this.item});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _numberFormat = NumberFormat('#,##0', 'id_ID');

  String _name = '';
  String _description = '';
  String _category = '';
  double _price = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name;
      _description = widget.item!.description;
      _category = widget.item!.category;
      _price = widget.item!.price;
      _imageFile = File(widget.item!.imagePath);
    }
  }

  void _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Sumber Gambar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Kamera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Galeri'),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      _formKey.currentState!.save();

      final newItem = Item(
        id: widget.item?.id, // Jika item sudah ada, gunakan ID-nya.
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        imagePath: _imageFile!.path,
      );

      if (widget.item == null) {
        // Tambah item baru.
        await _dbHelper.insertItem(newItem);
      } else {
        // Perbarui item yang ada.
        await _dbHelper.updateItem(newItem);
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar belum dipilih!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Tambah Barang' : 'Edit Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Barang
              Center(
                child: Stack(
                  children: [
                    _imageFile == null
                        ? Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.image,
                                size: 60, color: Colors.white70),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Input Nama Barang
              _buildTextField(
                label: 'Nama Barang',
                initialValue: _name,
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),

              // Input Deskripsi
              _buildTextField(
                label: 'Deskripsi',
                initialValue: _description,
                onSaved: (value) => _description = value!,
              ),

              // Input Kategori
              _buildTextField(
                label: 'Kategori',
                initialValue: _category,
                onSaved: (value) => _category = value!,
              ),

              // Input Harga
              _buildTextField(
                label: 'Harga',
                initialValue: _price == 0 ? '' : _numberFormat.format(_price),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _price = double.parse(value!.replaceAll('.', '')),
                validator: (value) =>
                    value!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),

              SizedBox(height: 20),
              // Tombol Simpan
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _saveItem,
                  icon: Icon(Icons.save),
                  label: Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget Helper untuk TextField
  Widget _buildTextField({
    required String label,
    required String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
