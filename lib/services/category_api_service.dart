import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tomado/models/category_model.dart';
import 'package:tomado/widgets/personal_pomodoro_widget.dart';

class CategoryApiService {
  final String baseUrl = 'http://43.201.79.243:8080/categories';

  Future<void> createCategory(int userId, String title, String color) async {
    var url = Uri.parse(baseUrl);
   
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'title': title, 'color': color}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
   
      return print('생성성공');
    } else {
     
      throw Exception('카테고리 생성 실패: ${json.decode(response.body)['message']}');
    }
  }

  Future<List<CategoryModel>> getCategories(int userId) async {
    var url = Uri.parse('$baseUrl/$userId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        final categoryList = data['data']['categoryList'];
        if (categoryList is List) {
          return categoryList
              .map((item) => CategoryModel.fromJson(item))
              .toList();
        }
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 404) {
      throw Exception('존재하지 않는 아이디');
    } else {
      throw Exception(
          'Failed to load categories: Status code ${response.statusCode}');
    }
  }

  Future<void> updateCategory(
      int categoryId, int userId, String title, String color) async {
    var url = Uri.parse('$baseUrl/$categoryId');
    var response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'color': color,
      }),
    );

    if (response.statusCode == 200) {
      print("수정 성공");
    } else {
      var responseData = json.decode(response.body);
      throw Exception('${responseData['status']}: ${responseData['message']}');
    }
  }

  Future<List<CategoryModel>> getClubCategories(int userId) async {
    var url = Uri.parse('$baseUrl/club/$userId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        final categoryList = data['data']['categoryList'];
        if (categoryList is List) {
          return categoryList
              .map((item) => CategoryModel.fromJson(item))
              .toList();
        }
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 404) {
      throw Exception('존재하지 않는 아이디');
    } else {
      throw Exception(
          'Failed to load categories: Status code ${response.statusCode}');
    }
  }
}
