import 'package:flutter/material.dart';
import 'package:j_tour/core/constan.dart';

class OperatingHoursWidget extends StatefulWidget {
  final TextEditingController weekdaysHoursController;
  final TextEditingController weekendHoursController;

  const OperatingHoursWidget({
    Key? key,
    required this.weekdaysHoursController,
    required this.weekendHoursController,
  }) : super(key: key);

  @override
  State<OperatingHoursWidget> createState() => _OperatingHoursWidgetState();
}

class _OperatingHoursWidgetState extends State<OperatingHoursWidget> {
  TimeOfDay? weekdayStartTime;
  TimeOfDay? weekdayEndTime;
  TimeOfDay? weekendStartTime;
  TimeOfDay? weekendEndTime;

  @override
  void initState() {
    super.initState();
    _parseExistingTimes();
  }

  void _parseExistingTimes() {
    // Parse existing values if any
    if (widget.weekdaysHoursController.text.isNotEmpty) {
      final parts = widget.weekdaysHoursController.text.split(' - ');
      if (parts.length == 2) {
        weekdayStartTime = _parseTimeString(parts[0]);
        weekdayEndTime = _parseTimeString(parts[1]);
      }
    }
    
    if (widget.weekendHoursController.text.isNotEmpty) {
      final parts = widget.weekendHoursController.text.split(' - ');
      if (parts.length == 2) {
        weekendStartTime = _parseTimeString(parts[0]);
        weekendEndTime = _parseTimeString(parts[1]);
      }
    }
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.trim().split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _updateWeekdayController() {
    if (weekdayStartTime != null && weekdayEndTime != null) {
      widget.weekdaysHoursController.text = 
          '${_formatTimeOfDay(weekdayStartTime!)} - ${_formatTimeOfDay(weekdayEndTime!)}';
    }
  }

  void _updateWeekendController() {
    if (weekendStartTime != null && weekendEndTime != null) {
      widget.weekendHoursController.text = 
          '${_formatTimeOfDay(weekendStartTime!)} - ${_formatTimeOfDay(weekendEndTime!)}';
    }
  }

  Future<void> _selectTime({
    required bool isWeekday,
    required bool isStartTime,
  }) async {
    final TimeOfDay? currentTime = isWeekday
        ? (isStartTime ? weekdayStartTime : weekdayEndTime)
        : (isStartTime ? weekendStartTime : weekendEndTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: kBlackColor,
              dayPeriodTextColor: kBlackColor,
              dialHandColor: kBlueColor,
              dialBackgroundColor: kBlueColor.withOpacity(0.1),
              hourMinuteColor: kBlueColor.withOpacity(0.1),
              dayPeriodColor: kBlueColor.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWeekday) {
          if (isStartTime) {
            weekdayStartTime = picked;
          } else {
            weekdayEndTime = picked;
          }
          _updateWeekdayController();
        } else {
          if (isStartTime) {
            weekendStartTime = picked;
          } else {
            weekendEndTime = picked;
          }
          _updateWeekendController();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlackColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBlueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  color: kBlueColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Operasional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kBlackColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Atur waktu operasional bisnis Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: kBlackColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Weekdays Input
          _buildTimeInputCard(
            title: 'Hari Kerja',
            subtitle: 'Senin - Jumat',
            icon: Icons.business_center_outlined,
            startTime: weekdayStartTime,
            endTime: weekdayEndTime,
            onStartTimePressed: () => _selectTime(isWeekday: true, isStartTime: true),
            onEndTimePressed: () => _selectTime(isWeekday: true, isStartTime: false),
            gradientColors: [
              kBlueColor.withOpacity(0.1),
              kBlueColor.withOpacity(0.05),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Weekend Input
          _buildTimeInputCard(
            title: 'Akhir Pekan',
            subtitle: 'Sabtu - Minggu',
            icon: Icons.weekend_outlined,
            startTime: weekendStartTime,
            endTime: weekendEndTime,
            onStartTimePressed: () => _selectTime(isWeekday: false, isStartTime: true),
            onEndTimePressed: () => _selectTime(isWeekday: false, isStartTime: false),
            gradientColors: [
              kWhiteColor,
              kWhiteColor.withOpacity(0.8),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kBlueColor.withOpacity(0.03),
                  kBlueColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kBlueColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBlueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.touch_app_outlined,
                    color: kBlueColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cara Penggunaan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kBlackColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ketuk tombol waktu untuk memilih jam buka dan tutup',
                        style: TextStyle(
                          fontSize: 12,
                          color: kBlackColor.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInputCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required VoidCallback onStartTimePressed,
    required VoidCallback onEndTimePressed,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBlackColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kBlackColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: kBlueColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kBlackColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: kBlackColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Time Selection Row
            Row(
              children: [
                // Start Time Button
                Expanded(
                  child: _buildTimeButton(
                    label: 'Jam Buka',
                    time: startTime,
                    onPressed: onStartTimePressed,
                    icon: Icons.login_outlined,
                  ),
                ),
                
                // Separator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_forward,
                    color: kBlackColor.withOpacity(0.4),
                    size: 20,
                  ),
                ),
                
                // End Time Button
                Expanded(
                  child: _buildTimeButton(
                    label: 'Jam Tutup',
                    time: endTime,
                    onPressed: onEndTimePressed,
                    icon: Icons.logout_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    final bool hasTime = time != null;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasTime ? kBlueColor.withOpacity(0.3) : kBlackColor.withOpacity(0.1),
            width: hasTime ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: kBlackColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: hasTime ? kBlueColor : kBlackColor.withOpacity(0.4),
                  size: 10,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: kBlackColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasTime ? _formatTimeOfDay(time!) : '--:--',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: hasTime ? kBlackColor : kBlackColor.withOpacity(0.3),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}