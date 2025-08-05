// lib/screens/write_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  Uint8List? _webImage;
  final _picker = ImagePicker();
  bool _isPickingImage = false;

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // 색상 팔레트
  static const Color _primaryColor = Color(0xFFFF597B);
  static const Color _secondaryColor = Color(0xFFFF8E9E);
  static const Color _accentColor = Color(0xFFF9B5D0);
  static const Color _backgroundColor = Color(0xFFEEEEEE);

  // 가격 선택
  final List<String> _priceOptions = [
    '3만원 이하',
    '5만원 이하',
    '10만원 이하',
    '10만원 초과',
  ];
  String? _selectedPrice;

  // 시간 선택 (double 제네릭)
  final List<double> _timeOptions = List.generate(16, (i) => 0.5 * (i + 1));
  double? _selectedTime;

  // 해시태그 선택
  final List<String> _allTags = [
    '맛집', '데이트', '여행', '카페', '야경', '문화', '산책', '힐링',
  ];
  final Set<String> _selectedTags = {};

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (img != null) {
        if (kIsWeb) {
          final bytes = await img.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _pickedImage = img);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e'), backgroundColor: _primaryColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _savePost() {
    if ((kIsWeb ? _webImage == null : _pickedImage == null) || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('이미지와 제목을 입력해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_selectedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('가격을 선택해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('소요 시간을 선택해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('최소 하나 이상의 태그를 선택해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }

    final newPost = Post(
      imagePath: kIsWeb ? null : _pickedImage!.path,
      webImageBytes: kIsWeb ? _webImage : null,
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          '게시글 작성',
          style: TextStyle(
            fontFamily: 'Cafe24Ssurround',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          TextButton(onPressed: _savePost,
            child: const Text('완료', style: TextStyle(
              fontFamily: 'Cafe24Ssurround',
              color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 이미지 업로드 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
            ),
            child: Row(children: [
              GestureDetector(
                onTap: _isPickingImage ? null : _pickImage,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: (kIsWeb ? _webImage != null : _pickedImage != null)
                        ? null : _accentColor.withAlpha(80),
                    border: Border.all(color: _secondaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isPickingImage
                      ? Center(child: CircularProgressIndicator(color: _primaryColor, strokeWidth: 2))
                      : kIsWeb
                          ? (_webImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(_webImage!, fit: BoxFit.cover))
                              : const Icon(Icons.add, size: 28, color: Colors.grey))
                          : (_pickedImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(10),
                                  child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                              : const Icon(Icons.add, size: 28, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 16),
              if ((kIsWeb ? _webImage : _pickedImage) == null)
                Text('사진을 추가해주세요',
                  style: TextStyle(fontFamily: 'Cafe24Ssurround', color: _primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 24),

          // 제목
          _buildInputField(label: '제목', controller: _titleCtrl, hint: '제목을 입력해주세요', maxLines: 1),
          const SizedBox(height: 20),

          // 내용
          _buildInputField(label: '내용', controller: _contentCtrl, hint: '내용을 작성해주세요', maxLines: 4),
          const SizedBox(height: 20),

          // 가격
          _buildDropdownField<String>(
            label: '가격',
            value: _selectedPrice,
            items: _priceOptions.map((p) =>
              DropdownMenuItem(value: p, child: Text(p))
            ).toList(),
            onChanged: (v) => setState(() => _selectedPrice = v),
          ),
          const SizedBox(height: 20),

          // 소요 시간 (double)
          _buildDropdownField<double>(
            label: '소요 시간',
            value: _selectedTime,
            items: _timeOptions.map((t) =>
              DropdownMenuItem(value: t, child: Text('${t}시간'))
            ).toList(),
            onChanged: (v) => setState(() => _selectedTime = v),
          ),
          const SizedBox(height: 24),

          // 해시태그
          _buildTagSelector(),

          const SizedBox(height: 40),

          // 등록 버튼
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
        const SizedBox(height: 12),
        TextField(
          controller: controller, maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: _accentColor.withAlpha(30),
          ),
        ),
      ]),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: _accentColor.withAlpha(30),
          ),
        ),
      ]),
    );
  }

  Widget _buildTagSelector() {
    return Container(
      padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('태그 선택 (최소 1개)', style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: _allTags.map((tag) {
          final selected = _selectedTags.contains(tag);
          return GestureDetector(
            onTap: () => setState(() {
              if (selected) _selectedTags.remove(tag); else _selectedTags.add(tag);
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? _primaryColor : _accentColor.withAlpha(60),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _primaryColor : _secondaryColor, width: 1.5),
              ),
              child: Text(tag, style: TextStyle(
                fontFamily: 'Cafe24Ssurround',
                color: selected ? Colors.white : _primaryColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              )),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryColor, _secondaryColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _primaryColor.withAlpha(80), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: ElevatedButton(
        onPressed: _savePost,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('게시글 등록', style: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
