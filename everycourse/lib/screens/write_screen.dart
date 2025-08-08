// lib/screens/write_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../services/region_service.dart';

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
  final _priceCtrl = TextEditingController();    // 가격 입력 컨트롤러
  final _timeCtrl = TextEditingController();     // 시간 입력 컨트롤러
  final _locationCtrl = TextEditingController(); // 학교 입력 컨트롤러
  final _regionCtrl = TextEditingController();   // 지역 입력 컨트롤러
  final _placeCtrl = TextEditingController();    // 장소 입력 컨트롤러
  
  List<String> _places = []; // 입력된 장소들 리스트
  
  // Region 관련
  final RegionService _regionService = RegionService();

  // 자동완성 관련
  List<String> _allSchoolNames = [];
  List<String> _allRegionNames = [];
  List<String> _allHashtags = []; // 기존 해시태그들
  List<String> _filteredSchools = [];
  List<String> _filteredRegions = [];
  List<String> _filteredHashtags = []; // 필터된 해시태그들
  bool _showSchoolSuggestions = false;
  bool _showRegionSuggestions = false;
  bool _showHashtagSuggestions = false; // 해시태그 자동완성 표시 여부

  // 색상 팔레트
  static const Color _primaryColor = Color(0xFFFF597B);
  static const Color _secondaryColor = Color(0xFFFF8E9E);
  static const Color _accentColor = Color(0xFFF9B5D0);
  static const Color _backgroundColor = Color(0xFFEEEEEE);

  // 해시태그 선택
  final List<String> _allTags = [
    '맛집', '데이트', '여행', '카페', '야경', '문화', '산책', '힐링',
  ];
  final Set<String> _selectedTags = {};
  final _hashtagCtrl = TextEditingController(); // 해시태그 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadAutocompleteData();
  }

  // 자동완성 데이터 로드
  Future<void> _loadAutocompleteData() async {
    try {
      final schoolNames = await _regionService.getAllSchoolNames();
      final regionNames = await _regionService.getAllRegionNames();
      final hashtags = await _regionService.getAllHashtags();
      
      setState(() {
        _allSchoolNames = schoolNames;
        _allRegionNames = regionNames;
        _allHashtags = hashtags;
      });
    } catch (e) {
      print('자동완성 데이터 로드 오류: $e');
    }
  }

  // 학교명 필터링
  void _filterSchools(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSchoolSuggestions = false;
        _filteredSchools = [];
      });
      return;
    }

    final filtered = _allSchoolNames
        .where((school) => school.toLowerCase().contains(query.toLowerCase()))
        .take(5) // 최대 5개만 표시
        .toList();

    setState(() {
      _filteredSchools = filtered;
      _showSchoolSuggestions = filtered.isNotEmpty;
    });
  }

  // 지역명 필터링
  void _filterRegions(String query) {
    if (query.isEmpty) {
      setState(() {
        _showRegionSuggestions = false;
        _filteredRegions = [];
      });
      return;
    }

    final filtered = _allRegionNames
        .where((region) => region.toLowerCase().contains(query.toLowerCase()))
        .take(5) // 최대 5개만 표시
        .toList();

    setState(() {
      _filteredRegions = filtered;
      _showRegionSuggestions = filtered.isNotEmpty;
    });
  }

  // 해시태그 필터링
  void _filterHashtags(String query) {
    if (query.isEmpty) {
      setState(() {
        _showHashtagSuggestions = false;
        _filteredHashtags = [];
      });
      return;
    }

    final filtered = _allHashtags
        .where((hashtag) => hashtag.toLowerCase().contains(query.toLowerCase()))
        .take(5) // 최대 5개만 표시
        .toList();

    setState(() {
      _filteredHashtags = filtered;
      _showHashtagSuggestions = filtered.isNotEmpty;
    });
  }

  // 자동완성 숨기기
  void _hideAllSuggestions() {
    setState(() {
      _showSchoolSuggestions = false;
      _showRegionSuggestions = false;
      _showHashtagSuggestions = false;
      _filteredSchools = [];
      _filteredRegions = [];
      _filteredHashtags = [];
    });
  }

  // 학교 선택
  void _selectSchool(String school) {
    _locationCtrl.text = school;
    _hideAllSuggestions();
    FocusScope.of(context).unfocus(); // 키보드 숨기기
  }

  // 지역 선택
  void _selectRegion(String region) {
    _regionCtrl.text = region;
    _hideAllSuggestions();
    FocusScope.of(context).unfocus(); // 키보드 숨기기
  }

  // 해시태그 선택
  void _selectHashtag(String hashtag) {
    setState(() {
      _selectedTags.add(hashtag);
      _hashtagCtrl.clear();
    });
    _hideAllSuggestions();
    FocusScope.of(context).unfocus(); // 키보드 숨기기
  }

  // 학교와 지역 정보를 저장하는 메서드
  Future<void> _saveLocationAndRegion() async {
    final location = _locationCtrl.text.trim();
    final region = _regionCtrl.text.trim();
    
    if (location.isNotEmpty && region.isNotEmpty) {
      // 기존 지역 확인 (regionName으로 검색)
      final existingRegion = await _regionService.findRegionByLocation(location);
      
      if (existingRegion == null) {
        // 새로운 학교인 경우
        final existingRegionByName = await _regionService.findRegionByName(region);
        
        if (existingRegionByName != null) {
          // 기존 지역에 새 학교 추가
          await _regionService.addLocationToRegion(existingRegionByName, location);
        } else {
          // 새 지역 생성 (Firebase 자동 ID 사용)
          await _regionService.createRegion(region, location);
        }
      }
    }
  }

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

  void _savePost() async {
    if ((kIsWeb ? _webImage == null : _pickedImage == null) || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('이미지와 제목을 입력해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_priceCtrl.text.isEmpty || int.tryParse(_priceCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('유효한 가격을 입력해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_timeCtrl.text.isEmpty || int.tryParse(_timeCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('유효한 소요 시간(분)을 입력해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('최소 하나 이상의 태그를 선택해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('최소 하나 이상의 장소를 입력해주세요!'), backgroundColor: _primaryColor),
      );
      return;
    }
    
    // 학교와 지역 정보 저장 (게시글 저장 전에)
    await _saveLocationAndRegion();

    final newPost = Post(
      imagePath: kIsWeb ? null : _pickedImage!.path,
      webImageBytes: kIsWeb ? _webImage : null,
      title: _titleCtrl.text,
      content: _contentCtrl.text,
      priceAmount: _priceCtrl.text.isEmpty ? null : int.tryParse(_priceCtrl.text),
      timeMinutes: _timeCtrl.text.isEmpty ? null : int.tryParse(_timeCtrl.text),
      hashtags: _selectedTags.toList(),
      places: _places.isNotEmpty ? _places : null,
      location: _locationCtrl.text.isEmpty ? null : _locationCtrl.text,
      rating: 0.0,
      reviewCount: 0,
      likes: 0,
    );
    widget.onAdd(newPost);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _priceCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 외부 터치 시 자동완성 숨기기 및 키보드 숨기기
        _hideAllSuggestions();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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

          // 학교
          _buildLocationField(),
          const SizedBox(height: 20),

          // 가격 (원 단위)
          _buildInputField(
            label: '가격 (원)', 
            controller: _priceCtrl, 
            hint: '예: 50000', 
            maxLines: 1,
            keyboardType: TextInputType.number
          ),
          const SizedBox(height: 20),

          // 소요 시간 (분 단위)
          _buildInputField(
            label: '소요 시간 (분)', 
            controller: _timeCtrl, 
            hint: '예: 120', 
            maxLines: 1,
            keyboardType: TextInputType.number
          ),
          const SizedBox(height: 24),

          // 장소 입력
          _buildPlaceSelector(),
          const SizedBox(height: 24),

          // 해시태그
          _buildTagSelector(),

          const SizedBox(height: 40),

          // 등록 버튼
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ]),
      ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      padding: const EdgeInsets.all(20), 
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(
            '학교 정보 (선택사항)', 
            style: TextStyle(
              fontFamily: 'Cafe24Ssurround', 
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: _primaryColor
            )
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextField(
                      controller: _locationCtrl, 
                      style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 16),
                      onChanged: _filterSchools,
                      onTap: () {
                        if (_locationCtrl.text.isNotEmpty) {
                          _filterSchools(_locationCtrl.text);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '학교명을 입력해주세요',
                        hintStyle: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), 
                          borderSide: BorderSide(color: _accentColor)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), 
                          borderSide: BorderSide(color: _primaryColor, width: 2)
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: _accentColor.withAlpha(30),
                      ),
                    ),
                    // 학교 자동완성 목록
                    if (_showSchoolSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _accentColor),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredSchools.length,
                          itemBuilder: (context, index) {
                            final school = _filteredSchools[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                school,
                                style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 14),
                              ),
                              onTap: () => _selectSchool(school),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    TextField(
                      controller: _regionCtrl,
                      style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 16),
                      onChanged: _filterRegions,
                      onTap: () {
                        if (_regionCtrl.text.isNotEmpty) {
                          _filterRegions(_regionCtrl.text);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '지역',
                        hintStyle: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), 
                          borderSide: BorderSide(color: _accentColor)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), 
                          borderSide: BorderSide(color: _primaryColor, width: 2)
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: _accentColor.withAlpha(30),
                      ),
                    ),
                    // 지역 자동완성 목록
                    if (_showRegionSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _accentColor),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredRegions.length,
                          itemBuilder: (context, index) {
                            final region = _filteredRegions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                region,
                                style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 14),
                              ),
                              onTap: () => _selectRegion(region),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
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
          controller: controller, 
          maxLines: maxLines,
          keyboardType: keyboardType,
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

  Widget _buildPlaceSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _secondaryColor.withAlpha(50), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('데이트 장소 (최소 1개)', 
            style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
          const SizedBox(height: 12),
          
          // 장소 입력 필드
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _placeCtrl,
                  style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '장소를 입력하세요 (예: 홍대 카페거리)',
                    hintStyle: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey[400]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: _accentColor.withAlpha(30),
                  ),
                  onSubmitted: (value) => _addPlace(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addPlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('추가', style: TextStyle(color: Colors.white, fontFamily: 'Cafe24Ssurround')),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 추가된 장소들 표시
          if (_places.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _places.asMap().entries.map((entry) {
                int index = entry.key;
                String place = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withAlpha(100),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(place, style: TextStyle(
                        fontFamily: 'Cafe24Ssurround',
                        color: _primaryColor,
                        fontSize: 14,
                      )),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removePlace(index),
                        child: Icon(Icons.close, size: 16, color: _primaryColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text('데이트 장소를 최소 1개 이상 추가해주세요', 
                    style: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addPlace() {
    if (_placeCtrl.text.trim().isNotEmpty) {
      setState(() {
        _places.add(_placeCtrl.text.trim());
        _placeCtrl.clear();
      });
    }
  }

  void _removePlace(int index) {
    setState(() {
      _places.removeAt(index);
    });
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
        
        // 해시태그 텍스트 입력 필드
        Column(
          children: [
            TextField(
              controller: _hashtagCtrl,
              style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 16),
              onChanged: _filterHashtags,
              onTap: () {
                if (_hashtagCtrl.text.isNotEmpty) {
                  _filterHashtags(_hashtagCtrl.text);
                }
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty && !_selectedTags.contains(value.trim())) {
                  setState(() {
                    _selectedTags.add(value.trim());
                    _hashtagCtrl.clear();
                  });
                  _hideAllSuggestions();
                }
              },
              decoration: InputDecoration(
                hintText: '해시태그를 입력하거나 아래에서 선택해주세요',
                hintStyle: TextStyle(fontFamily: 'Cafe24Ssurround', color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accentColor)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2)
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: _accentColor.withAlpha(30),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: _primaryColor),
                  onPressed: () {
                    final value = _hashtagCtrl.text.trim();
                    if (value.isNotEmpty && !_selectedTags.contains(value)) {
                      setState(() {
                        _selectedTags.add(value);
                        _hashtagCtrl.clear();
                      });
                      _hideAllSuggestions();
                    }
                  },
                ),
              ),
            ),
            
            // 해시태그 자동완성 목록
            if (_showHashtagSuggestions)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _accentColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredHashtags.length,
                  itemBuilder: (context, index) {
                    final hashtag = _filteredHashtags[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        hashtag,
                        style: const TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 14),
                      ),
                      leading: Icon(Icons.tag, color: _primaryColor, size: 18),
                      onTap: () => _selectHashtag(hashtag),
                    );
                  },
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 선택된 해시태그들 표시
        if (_selectedTags.isNotEmpty) ...[
          Text('선택된 태그:', style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 14, fontWeight: FontWeight.w600, color: _primaryColor)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _selectedTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tag, style: const TextStyle(
                    fontFamily: 'Cafe24Ssurround',
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  )),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() {
                      _selectedTags.remove(tag);
                    }),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
        ],
        
        // 기본 해시태그 선택지
        Text('추천 태그:', style: TextStyle(fontFamily: 'Cafe24Ssurround', fontSize: 14, fontWeight: FontWeight.w600, color: _primaryColor)),
        const SizedBox(height: 8),
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
