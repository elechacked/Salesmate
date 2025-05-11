// lib/features/employee/controller/employee_home_controller.dart
import 'package:get/get.dart';
import 'package:salesmate/core/services/visit_service.dart';
import 'package:salesmate/models/visit_models.dart';

import '../../auth/controller/auth_controller.dart';

class EmployeeHomeController extends GetxController {
  final VisitService _visitService = Get.find<VisitService>();
  final RxList<Visit> completedVisits = <Visit>[].obs;
  final RxList<Visit> ongoingVisits = <Visit>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVisits();
    ever(_visitService.visitsNeedRefresh, (_) => loadVisits());
  }

  Future<void> loadVisits() async {
    try {
      isLoading.value = true;
      final user = Get.find<AuthController>().currentUser;
      if (user == null || user.companyId == null) return;

      final visits = await _visitService.getEmployeeVisits(
        user.companyId!,
        user.email,
      );

      _updateVisitLists(visits);
    } catch (e) {
      errorMessage.value = 'Failed to load visits: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _updateVisitLists(List<Visit> visits) {
    completedVisits.assignAll(visits.where((v) => !v.isOngoing));
    ongoingVisits.assignAll(visits.where((v) => v.isOngoing));
  }

  Future<void> refreshVisits() async {
    await loadVisits();
  }
}