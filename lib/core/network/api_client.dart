import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../local/secure_storage.dart';

/// Single Dio instance shared by all network services.
///
/// **Why this exists:**
/// The original VisitorService and ComplaintService each created their own
/// bare Dio instance with no Authorization header. Once the backend gained
/// JWT-protected routes, every offline sync attempt returned HTTP 401, which
/// was silently swallowed by the catch block — leaving entries permanently
/// stuck as "unsynced".
///
/// This client attaches the stored JWT to every request automatically, so
/// sync calls succeed whether they are triggered immediately after adding an
/// entry, or later by the ConnectivityWrapper's reconnect handler.
class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static bool _initialised = false;

  /// Call once from main() after dotenv is loaded.
  static void init() {
    if (_initialised) return;
    _initialised = true;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // 401 means the token is invalid or expired — propagate so the
          // caller (e.g. _syncVisitor) can surface it rather than silently
          // dropping the entry forever.
          handler.next(error);
        },
      ),
    );
  }

  static Dio get instance {
    assert(_initialised, 'ApiClient.init() must be called before use.');
    return _dio;
  }
}
