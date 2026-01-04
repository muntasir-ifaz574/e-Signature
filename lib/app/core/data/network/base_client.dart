abstract class BaseClient {
  Future<dynamic> getApi({
    required String url,
    Map<String, dynamic>? data,
    required dynamic context,
  });

  Future<dynamic> postApi({
    required String url,
    dynamic data,
    required dynamic context,
  });

  Future<dynamic> updateApi({
    required String url,
    dynamic data,
    required dynamic context,
  });

  Future<dynamic> deleteApi({required String url, required dynamic context});
}
