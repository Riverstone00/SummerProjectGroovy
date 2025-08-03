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
  final _contentCtrl = TextEditingController();

  // 1. 가격 선택 옵션
  final List<String> _priceOptions = [
    '3만원 이하',
    '5만원 이하',
    '10만원 이하',
    '10만원 이상',
  ];
  String? _selectedPrice;

  // 2. 시간 선택 옵션 (0.5 단위)
  final List<double> _timeOptions = List.generate(16, (i) => 0.5 * (i+1)); // 0.5 ~ 8.0
  double? _selectedTime;

  // 3. 해시태그 선택 (8개 중 최소 1개)
  final List<String> _allTags = [
    '맛집',
    '데이트',
    '여행',
    '카페',
    '야경',
    '문화',
    '산책',
    '힐링',
  ];
  final Set<String> _selectedTags = {};

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (img != null) {
      setState(() => _pickedImage = img);
    }
  }

  void _savePost() {
    if (_pickedImage == null || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지와 제목을 입력해주세요!')),
      );
      return;
    }
    if (_selectedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가격을 선택해주세요!')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소요 시간을 선택해주세요!')),
      );
      return;
    }
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나 이상의 태그를 선택해주세요!')),
      );
      return;
    }

    final newPost = Post(
      imagePath: _pickedImage!.path,
      title: _titleCtrl.text,
      price: _selectedPrice,
      duration: '$_selectedTime시간',
      tags: _selectedTags.toList(),
      content: _contentCtrl.text,
    );
    widget.onAdd(newPost);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
        backgroundColor: Colors.pink,
        actions: [
          TextButton(onPressed: _savePost, child: const Text('완료', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 이미지 업로드
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
                      child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.add_a_photo, size: 50, color: Colors.pink),
                    ),
            ),
          ),

          const SizedBox(height: 24),
          // 제목
          const Text('제목', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: '제목을 입력해주세요')),

          const SizedBox(height: 16),
          // 내용
          const Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _contentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(hintText: '내용을 작성해주세요'),
          ),

          const SizedBox(height: 16),
          // 1. 가격 선택
          const Text('가격', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPrice,
            items: _priceOptions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPrice = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 16),
          // 2. 시간 선택
          const Text('소요 시간', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            value: _selectedTime,
            items: _timeOptions
                .map((t) => DropdownMenuItem(value: t, child: Text('${t}시간')))
                .toList(),
            onChanged: (v) => setState(() => _selectedTime = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 16),
          // 3. 해시태그 선택
          const Text('태그 선택 (최소 1개)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return ChoiceChip(
                label: Text(tag),
                selected: selected,
                selectedColor: Colors.pinkAccent,
                onSelected: (on) {
                  setState(() {
                    if (on) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          // 등록 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _savePost,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text('게시글 등록', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
