// lib/screens/write_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

class WriteScreen extends StatefulWidget {
  final Function(Post) onAdd;
  const WriteScreen({super.key, required this.onAdd});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  XFile? _pickedImage;
  final _picker = ImagePicker();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    setState(() => _pickedImage = image);
  }

  void _savePost() {
    if (_pickedImage == null || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지와 제목을 입력해주세요!')),
      );
      return;
    }
    
    final newPost = Post(
      imagePath: _pickedImage!.path,
      title: _titleCtrl.text,
      price: _priceCtrl.text.isEmpty ? null : _priceCtrl.text,
      duration: _durationCtrl.text.isEmpty ? null : _durationCtrl.text,
    );
    
    widget.onAdd(newPost);
    Navigator.of(context).pop(); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
        actions: [
          TextButton(
            onPressed: _savePost,
            child: const Text('완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.pink),
                            SizedBox(height: 8),
                            Text('사진을 등록해주세요'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: '작성해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: '가격 정보를 추가해주세요.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationCtrl,
                decoration: const InputDecoration(
                  labelText: '소요 시간을 추가해 주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '게시글 등록',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }
}
