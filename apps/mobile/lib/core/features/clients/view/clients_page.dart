import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:business_assistant/core/features/main_header/view/main_header.dart';

/// Placeholder for the Clients tab — replaced with the real UI later.
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      isHeaderVisible: false,
      pageHeader: MainHeader(),
      pageBody: SingleChildScrollView(
        child: Center(
          child: Text('Clients'),
        ),
      ),
    );
  }
}
