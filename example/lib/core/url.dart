import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

///op[en given url in browser
Future<void> launchLink(String link) async {
  final Uri url = Uri.parse(link);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    ///can not lauch url
    debugPrint('can not launch url');
  }
}
