class ApiEndpoints {
  // Use 10.0.2.2 for Android emulator or localhost for iOS/Web.
  // For physical devices, use the computer's actual local IP on the network.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Maintenance endpoints
  static const String maintenance = '/maintenance';
  static String maintenanceDetail(String id) => '/maintenance/$id';
  static String maintenanceAssign(String id) => '/maintenance/$id/assign';

  // Provider endpoints
  static const String providers = '/providers';
  static String providerDetail(String id) => '/providers/$id';

  // Notifications
  static const String notifications = '/notifications/';

  // Visits
  static const String visits = '/visits/';
}
