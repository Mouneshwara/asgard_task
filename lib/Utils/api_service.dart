import 'package:asgard_task/Utils/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ApiService {
  API api = API();

  ///TO CHECK CONNECTIVITY
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  ///GET
  Future<Response<dynamic>> getResponseBody({required String url}) async {
    if (await _isConnected()) {
      Response response = await api.sendRequest.get(url,
          options: Options(headers: {"Content-Type": "application/json"}));
      return response;
    } else {
      throw Exception('No internet connection');
    }
  }

  ///POST
  Future<Response<dynamic>> postResponseBody(
      {required String url, reqObj}) async {
    if (await _isConnected()) {
      Response response = await api.sendRequest.post(
        url,
        data: reqObj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response;
    } else {
      throw Exception('No internet connection');
    }
  }

  ///DELETE
  Future<dynamic> deleteResponseBody({required String url}) async {
    if (await _isConnected()) {
      Response response = await api.sendRequest.delete(url,
          options: Options(headers: {"Content-Type": "application/json"}));
      return response;
    } else {
      throw Exception('No internet connection');
    }
  }

  ///NHS_GET
  Future<dynamic> getResponseBodyForNhs({required String url}) async {
    if (await _isConnected()) {
      Response response = await api.sendRequest.delete(url,
          options: Options(headers: {"Content-Type": "application/json"}));
      return response;
    } else {
      throw Exception('No internet connection');
    }
  }
}
