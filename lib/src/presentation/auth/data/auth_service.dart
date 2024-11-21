
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final String baseUrl = 'https://hris-api.alfanium.id/v1';

  // Fungsi untuk melakukan login
  Future<Either<String, Map<String, dynamic>>> doLogin({
    required String email,
    required String password,
  }) async {
    debugPrint("email => $email");
    debugPrint("password => $password");
    var body = {
      "email": email,
      "password": password,
    };
    try {
      var response = await Dio().post(
        "$baseUrl/loginByEmail",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: json.encode(body),
      );
      Map<String, dynamic> obj = response.data;
      debugPrint(obj.toString());
      return Right(obj); // Mengembalikan respons berhasil dengan data
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          return Left(e.response!.data['message']);
        }
        debugPrint(e.response!.statusMessage);
        debugPrint(e.response!.data);
      }
      return Left(e.toString());
    }
  }

  // Fungsi untuk mendapatkan data user berdasarkan token
  Future<Either<String, Map<String, dynamic>>> getUserById(String token) async {
    try {
      var response = await Dio().get(
        "$baseUrl/findById",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      Map<String, dynamic> data = response.data;
      if (data['success'] == true && data.containsKey('results')) {
        return Right(data['results']); // Mengembalikan data user
      } else {
        return Left('Gagal memuat data pengguna');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message'] ?? 'Gagal menghubungkan ke server');
      }
      return Left(e.toString());
    }
  }

  // Fungsi untuk melakukan registrasi
  Future<Either<String, Map<String, dynamic>>> doRegister({
    required String name,
    required String email,
    required String password,
    required String tanggalLahir,
    required String alamat,
    required String nomorTelp,
  }) async {
    try {
      var response = await Dio().post(
        "http://attendance-app.test/api/auth/register",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          "name": name,
          "email": email,
          "password": password,
          "tanggal_lahir": tanggalLahir,
          "alamat": alamat,
          "nomor_telp": nomorTelp,
        },
      );
      Map<String, dynamic> obj = response.data;
      return Right(obj);
    } on DioException catch (e) {
      if (e.response!.statusCode == 422) {
        final errorMessages = [];
        e.response!.data["errors"].forEach((field, errors) {
          final errorMessage = "$field: ${errors.join(', ')}";
          errorMessages.add(errorMessage);
        });
        final errorString = errorMessages.join('\n');
        return Left(errorString);
      }
      return Left(e.toString());
}
}
}
