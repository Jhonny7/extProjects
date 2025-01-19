import 'package:get/get.dart';
import '../models/clase.dart';
import '../models/review.dart';
import '../services/reviewService.dart';

class ReviewController extends GetxController {
  final ReviewService reviewService = Get.put(ReviewService());
  var reviews = <ReviewModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Obtener reviews de un profesor
  Future<void> fetchReviewsPorProfesor(String profesorId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final reviewsData = await reviewService.getReviewsPorProfesor(profesorId);
      reviews.assignAll(reviewsData);
    } catch (e) {
      errorMessage.value = 'Error al cargar las reviews';
    } finally {
      isLoading.value = false;
    }
  }

  // Crear una nueva review
  Future<void> crearReview(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await reviewService.crearReview(data);
    } catch (e) {
      errorMessage.value = 'Error al crear la review';
    } finally {
      isLoading.value = false;
    }
  }
}
