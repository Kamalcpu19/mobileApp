import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  ContactLauncher._();

  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\s+'), ''));
    return launchUrl(uri);
  }

  static Future<bool> sms(String phone, {String? body}) async {
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: body != null ? {'body': body} : null,
    );
    return launchUrl(uri);
  }

  static Future<bool> email(String address, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    return launchUrl(uri);
  }

  static Future<bool> whatsApp(String phone, {String? message}) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse(
      'https://wa.me/$normalized${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openUrl(String url) async {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
