import 'package:flutter/material.dart';

class PaginationTrigger extends StatelessWidget {
  final Widget child;
  final SliverAppBar? fixedContent;
  final void Function() onPagination;

  const PaginationTrigger({
    super.key,
    required this.child,
    this.fixedContent,
    required this.onPagination,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
            debugPrint('== SCROLLED TO BOTTOM ==');
            onPagination();
          }
        }
        return true;
      },
      // child: child, // ! First option
      child: Builder(builder: (context) {
        return CustomScrollView(
          slivers: [
            // Fixed content
            if (fixedContent != null) ...[
              fixedContent!,
            ],

            // Scroll section
            SliverToBoxAdapter(
              child: child,
            ),
          ],
        );
      }),
    );
  }
}
