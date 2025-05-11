// lib/features/company/presentation/visits/visit_detail.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:salesmate/features/company/controller/visits_controller.dart';
import 'package:salesmate/features/company/presentation/visits/widgets/visit_map_widget.dart';
import 'package:salesmate/models/visit_models.dart';

class VisitDetailScreen extends StatelessWidget {
  final VisitController _controller = Get.find<VisitController>();

  VisitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Details', style: AppTextStyles.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareVisitDetails,
            tooltip: 'Share Visit Details',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value || _controller.selectedVisit.value == null) {
          return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final visit = _controller.selectedVisit.value!;
        final checkInPos = LatLng(
          visit.checkInPosition.latitude,
          visit.checkInPosition.longitude,
        );
        final checkOutPos = visit.checkOutPosition != null
            ? LatLng(
          visit.checkOutPosition!.latitude,
          visit.checkOutPosition!.longitude,
        )
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(visit, theme),
              const SizedBox(height: 20),

              // Map Section
              Text('Visit Locations', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              VisitMapWidget(
                checkInPosition: checkInPos,
                checkOutPosition: checkOutPos,
                checkInTime: _controller.formatTime(visit.checkInTime),
                checkOutTime: visit.checkOutTime != null
                    ? _controller.formatTime(visit.checkOutTime!)
                    : null,
                isDarkMode: isDarkMode,
                showCurrentLocation: visit.isOngoing,
              ),
              const SizedBox(height: 20),

              // Timeline Section
              _buildTimelineSection(visit, theme),
              const SizedBox(height: 20),

              // Details Section
              _buildDetailsSection(visit, theme),
              const SizedBox(height: 20),

              // Photo Section
              if (visit.photoUrl.isNotEmpty) _buildPhotoSection(visit, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(Visit visit, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    visit.visitingCompanyName,
                    style: AppTextStyles.headlineMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    visit.isOngoing ? 'ONGOING' : 'COMPLETED',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: visit.isOngoing ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  backgroundColor: visit.isOngoing
                      ? AppColors.warning.withOpacity(0.2)
                      : AppColors.success.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Employee: ${_controller.selectedEmployee.value?.name ?? 'Unknown'}',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Visit ID: ${visit.id}',
              style: AppTextStyles.bodySmall.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(Visit visit, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit Timeline', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            _buildTimelineRow(
              icon: Icons.login,
              title: 'Check-in',
              value: _controller.formatTime(visit.checkInTime),
              theme: theme,
            ),
            if (!visit.isOngoing) ...[
              const Divider(height: 24),
              _buildTimelineRow(
                icon: Icons.logout,
                title: 'Check-out',
                value: _controller.formatTime(visit.checkOutTime!),
                theme: theme,
              ),
            ],
            const Divider(height: 24),
            _buildTimelineRow(
              icon: Icons.timer,
              title: 'Duration',
              value: visit.isOngoing ? 'In Progress' : visit.formattedDuration,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Visit visit, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit Details', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.assignment,
              label: 'Purpose',
              value: visit.visitPurpose ?? 'Not specified',
              theme: theme,
            ),
            _buildDetailRow(
              icon: Icons.person,
              label: 'Contact',
              value: visit.contactName ?? 'Not specified',
              subValue: visit.contactPhone,
              theme: theme,
            ),
            _buildDetailRow(
              icon: Icons.assessment,
              label: 'Outcome',
              value: visit.outcome ?? 'Not specified',
              theme: theme,
            ),
            if (visit.remarks != null)
              _buildDetailRow(
                icon: Icons.note,
                label: 'Remarks',
                value: visit.remarks!,
                theme: theme,
              ),
            _buildDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: visit.address ?? 'Not Yet Specified',
                theme: theme
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(Visit visit, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Check-in Photo', style: AppTextStyles.titleLarge),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Image.network(
              visit.photoUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => SizedBox(
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: theme.colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              )),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.hintColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall.copyWith(
                  color: theme.hintColor,
                )),
                Text(value, style: AppTextStyles.bodyMedium),
                if (subValue != null)
                  Text(subValue, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareVisitDetails() async {
    // Implement share functionality
    Get.snackbar('Info', 'Share functionality will be implemented');
  }
}