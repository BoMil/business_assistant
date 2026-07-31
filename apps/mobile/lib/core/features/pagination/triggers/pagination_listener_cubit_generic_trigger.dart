import 'package:business_assistant/core/features/pagination/pagination_cubit_base.dart';
import 'package:business_assistant/core/features/pagination/triggers/pagination_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenericPaginationTrigger<T extends PaginationCubitBase> extends StatelessWidget {
  const GenericPaginationTrigger({
    super.key,
    required this.child,
    this.fixedContent,
  });
  final Widget child;
  final SliverAppBar? fixedContent;

  @override
  Widget build(BuildContext context) {
    return PaginationTrigger(
      onPagination: () {
        if (!context.read<T>().isLoading && !context.read<T>().isAtEnd) {
          context.read<T>().getNextPage();
        }
      },
      fixedContent: fixedContent,
      child: child,
    );
  }
}
