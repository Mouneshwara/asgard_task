import 'package:asgard_task/ProductModule/Data_Layer/models/product_model.dart';
import 'package:asgard_task/Utils/api_service.dart';
import 'package:dio/dio.dart';

class ProductRepo {
  Future<List<ProductModel>> prodList() async {
    String fullUrl =
        "https://h2gvbfqo6smwzaby6x7jinzujm0otrjt.lambda-url.eu-west-2.on.aws/your-endpoint";
    Response response = await ApiService().getResponseBody(url: fullUrl);
    try {
      if (response.statusMessage != null) {
        List<dynamic> responseData = response.data;
        List<ProductModel> data =
            responseData.map((item) => ProductModel.fromJson(item)).toList();
        return data;
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      rethrow;
    }
  }
}
