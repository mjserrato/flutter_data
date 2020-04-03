part of flutter_data;

// necessary to massage data via external mixins
abstract class RemoteAdapter<T extends DataSupport<T>> {
  String get type => DataId.getType<T>();

  // expose locator to mixins
  Locator get locator;

  // url design

  String baseUrl = 'http://127.0.0.1:8080/';

  // FIXME when we get late fields
  UrlDesign _urlDesign;
  UrlDesign get urlDesign =>
      _urlDesign ??= PathBasedUrlDesign(Uri.parse(baseUrl));

  String updateHttpMethod = 'PATCH';

  Map<String, String> get headers => {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json',
      };

  // serialize/deserialize

  // Forwards data since flutter_data understands JSON:API
  Map<String, dynamic> deserialize(dynamic json,
          [Map<String, dynamic> relationshipMetadata]) =>
      json as Map<String, dynamic>;

  dynamic serialize(Map<String, dynamic> json) => json;

  // repository methods

  Future<List<T>> findAll(
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  @protected
  Future<List<T>> loadAll(
      {Map<String, String> params, Map<String, String> headers});

  DataStateNotifier<List<T>> watchAll(
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  Future<T> findOne(String id,
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  @protected
  Future<T> loadOne(String id,
      {Map<String, String> params, Map<String, String> headers});

  DataStateNotifier<T> watchOne(String id,
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  Future<T> save(T model,
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  Future<void> delete(String id,
      {bool remote = true,
      Map<String, String> params,
      Map<String, String> headers});

  @protected
  Future<R> withHttpClient<R>(OnRequest<R> onRequest);

  Future<void> dispose();
}