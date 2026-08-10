import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// It will open specified schema, for example email or phone dial native platform screen
///
/// `value` String representing the scheme value (phone numer or email)
///
/// `scheme` Scheme to open "tel", "mailto" for example
void launchSchema(UrlSchemes scheme, String? value) async {
  if (value != null) {
    try {
      final Uri params = Uri(scheme: scheme.name, path: value);

      if (await canLaunchUrl(params)) {
        await launchUrl(params);
      } else {
        debugPrint('Failed to launch scheme- $scheme');
      }
    } catch (e) {
      debugPrint('Failed to launch scheme- $scheme: $e');
    }
  }
}

/// It will open the web url link
///
/// `url` String representing the url
///
/// `errorMessage` Message that will be logged in case opening url failed
void launchWebUrl(String url, {String errorMessage = 'Failed to launch url'}) async {
  try {
    Uri parsedUrl = Uri.parse(url);
    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('$errorMessage: $url');
    }
  } catch (e) {
    // TODO: We should add a logging feature
    debugPrint('$errorMessage: $e');
  }
}

enum UrlSchemes { mailto, tel }
