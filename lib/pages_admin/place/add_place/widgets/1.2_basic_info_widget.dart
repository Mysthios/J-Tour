import 'package:flutter/material.dart';
import 'package:j_tour/core/constan.dart';

class BasicInfoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const BasicInfoWidget({
    Key? key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  // Category data with icons
  final List<Map<String, dynamic>> categories = const [
    {
      'value': 'Pantai',
      'label': 'Pantai',
      'icon': Icons.beach_access_rounded,
      'color': Color(0xFF00BCD4),
    },
    {
      'value': 'Air Terjun',
      'label': 'Air Terjun',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF2196F3),
    },
    {
      'value': 'Pegunungan',
      'label': 'Pegunungan',
      'icon': Icons.landscape_rounded,
      'color': Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlackColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern section header
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: kBlueColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Dasar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 24),

          // Name Field with modern styling
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Wisata',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                style: TextStyle(
                  fontSize: 16,
                  color: kBlackColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama tempat wisata',
                  hintStyle: TextStyle(
                    color: kBlackColor.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1,
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
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Section with modern cards
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Wisata',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 12),

              // Category cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category['value'];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onCategoryChanged(
                          selectedCategory == category['value']
                              ? null
                              : category['value']),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kBlueColor.withOpacity(0.1)
                              : kWhiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? kBlueColor
                                : kBlackColor.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: kBlueColor.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: kBlackColor.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kBlueColor
                                    : (category['color'] as Color)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : category['color'],
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? kBlueColor
                                    : kBlackColor.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Validation message for category
              if (selectedCategory == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Pilih salah satu kategori wisata',
                    style: TextStyle(
                      fontSize: 12,
                      color: kBlackColor.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Description Field with modern styling
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 16,
                  color: kBlackColor,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Ceritakan tentang keindahan dan keunikan tempat wisata ini...',
                  hintStyle: TextStyle(
                    color: kBlackColor.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: kBlueColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 16,
                    color: kBlackColor.withOpacity(0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tips: Deskripsikan fasilitas, aktivitas, dan daya tarik utama',
                    style: TextStyle(
                      fontSize: 10,
                      color: kBlackColor.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
