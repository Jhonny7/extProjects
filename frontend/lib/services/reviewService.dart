import 'package:dio/dio.dart';
import '../models/clase.dart';
import '../models/review.dart';

class ReviewService {
  final Dio dio = Dio();
  final String baseUrl = 'http://localhost:3000/api/reviews';

  Future<List<ReviewModel>> getReviewsPorProfesor(String profesorId) async {
    final response = await dio.get('$baseUrl/profesor/$profesorId');
    return (response.data as List).map((json) => ReviewModel.fromJson(json)).toList();
  }

  Future<void> crearReview(Map<String, dynamic> data) async {
    await dio.post(baseUrl, data: data);
  }
}
