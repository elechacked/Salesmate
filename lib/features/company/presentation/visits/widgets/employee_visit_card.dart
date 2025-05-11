import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/models/employee_models.dart';
import 'package:salesmate/models/visit_models.dart';
import 'package:salesmate/app/themes/app_colors.dart';

class EmployeeVisitCard extends StatelessWidget {
  final Employee employee;
  final int visitCount;
  final Visit? lastVisit;
  final String? lastVisitDate;
  final VoidCallback onTap;

  const EmployeeVisitCard({
    super.key,
    required this.employee,
    required this.visitCount,
    required this.lastVisit,
    this.lastVisitDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVisitOngoing = lastVisit?.isOngoing ?? false;
    final lastVisitTime = lastVisit != null
        ? DateFormat('MMM dd, hh:mm a').format(lastVisit!.checkInTime)
        : 'No visits';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar with Status
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: employee.profileImageUrl != null
                            ? NetworkImage(employee.profileImageUrl!)
                            : const AssetImage(AppImages.defaultAvatar)
                        as ImageProvider,
                      ),
                    ),
                    if (isVisitOngoing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Employee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.department ?? 'No department specified',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stats Row
                      Row(
                        children: [
                          // Total Visits
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EDFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_rounded,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$visitCount ${visitCount == 1 ? 'Visit' : 'Visits'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Last Visit Status
                          if (lastVisit != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isVisitOngoing
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVisitOngoing
                                        ? Icons.timer_rounded
                                        : Icons.check_circle_rounded,
                                    size: 14,
                                    color: isVisitOngoing
                                        ? AppColors.warning
                                        : AppColors.success,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isVisitOngoing
                                        ? 'In Progress'
                                        : 'Last: $lastVisitTime',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isVisitOngoing
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}