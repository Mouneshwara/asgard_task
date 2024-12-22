import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class API {
  final Dio _dio = Dio();
  API() {
    // _dio.options.baseUrl = "https://mocki.io/v1/";
    _dio.options.baseUrl =
        "https://h2gvbfqo6smwzaby6x7jinzujm0otrjt.lambda-url.eu-west-2.on.aws/";
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }
  Dio get sendRequest =>
      _dio; //for _dio private to use it in any external class
}
