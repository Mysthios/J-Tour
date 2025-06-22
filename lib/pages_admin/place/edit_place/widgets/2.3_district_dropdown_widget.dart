import 'package:flutter/material.dart';
import 'package:j_tour/core/constan.dart';

class DistrictDropdownWidget extends StatefulWidget {
  final TextEditingController locationController;

  const DistrictDropdownWidget({
    Key? key,
    required this.locationController,
  }) : super(key: key);

  @override
  State<DistrictDropdownWidget> createState() => _DistrictDropdownWidgetState();
}

class _DistrictDropdownWidgetState extends State<DistrictDropdownWidget>
    with TickerProviderStateMixin {
  final List<String> _jemberDistricts = [
    'Ajung',
    'Ambulu',
    'Arjasa',
    'Balung',
    'Bangsalsari',
    'Gumukmas',
    'Jelbuk',
    'Jenggawah',
    'Jombang',
    'Kalisat',
    'Kaliwates',
    'Kencong',
    'Ledokombo',
    'Mayang',
    'Mumbulsari',
    'Pakusari',
    'Patrang',
    'Puger',
    'Rambipuji',
    'Semboro',
    'Silo',
    'Sukorambi',
    'Sukowono',
    'Sumberbaru',
    'Sumberjambe',
    'Sumbersari',
    'Tanggul',
    'Tempurejo',
    'Umbulsari',
    'Wuluhan',
  ];

  List<String> _filteredDistricts = [];
  bool _showDropdown = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredDistricts = _jemberDistricts;

    // Initialize animation controller safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );

        _fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOutQuart,
        ));

        _scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOutBack,
        ));
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _showDropdown) {
        _hideDropdown();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterDistricts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDistricts = _jemberDistricts;
      } else {
        _filteredDistricts = _jemberDistricts
            .where((district) =>
                district.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      if (query.isNotEmpty && _filteredDistricts.isNotEmpty && !_showDropdown) {
        _showDropdown = true;
        _animationController?.forward();
      } else if (query.isEmpty || _filteredDistricts.isEmpty) {
        _hideDropdown();
      }
    });
  }

  void _showDropdownList() {
    setState(() {
      _showDropdown = true;
      _filteredDistricts = _jemberDistricts;
    });
    _animationController?.forward();
  }

  void _hideDropdown() {
    _animationController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showDropdown = false;
        });
      }
    });
  }

  void _selectDistrict(String district) {
    setState(() {
      widget.locationController.text = district;
    });
    _hideDropdown();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern title with gradient accent
        Container(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kBlueColor, kBlueColor.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lokasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Modern input field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kBlackColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextFormField(
                controller: widget.locationController,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: 16,
                  color: kBlackColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Kecamatan di Jember',
                  labelStyle: TextStyle(
                    color: kBlackColor.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'Pilih atau ketik kecamatan...',
                  hintStyle: TextStyle(
                    color: kBlackColor.withOpacity(0.4),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlueColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: _showDropdownList,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedRotation(
                        turns: _showDropdown ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kBlueColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kecamatan tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: _filterDistricts,
                onTap: _showDropdownList,
              ),
            ),

            // Animated dropdown list
            if (_showDropdown &&
                _filteredDistricts.isNotEmpty &&
                _animationController != null)
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation?.value ?? 1.0,
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: _fadeAnimation?.value ?? 1.0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kBlackColor.withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kBlackColor.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredDistricts.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 0.5,
                              color: kBlackColor.withOpacity(0.08),
                              indent: 56,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final district = _filteredDistricts[index];
                              final isSelected =
                                  widget.locationController.text == district;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _selectDistrict(district),
                                  splashColor: kBlueColor.withOpacity(0.1),
                                  highlightColor: kBlueColor.withOpacity(0.05),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? kBlueColor
                                                : kBlueColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            color: isSelected
                                                ? kWhiteColor
                                                : kBlueColor,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            district,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? kBlueColor
                                                  : kBlackColor,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: kBlueColor,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
