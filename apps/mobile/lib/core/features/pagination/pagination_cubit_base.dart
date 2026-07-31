import 'package:business_assistant/core/shared/models/base_multi_page_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaginationCubitBase<TClass, TState> extends Cubit<TState> {
  PaginationCubitBase(super.initialState);

  int page = 1;

  bool isLoading = false;

  BaseMultiPageResponse<TClass> data = BaseMultiPageResponse<TClass>.empty();

  bool get isAtEnd => data.items.length >= data.count;

  String searchTerm = '';

  getNextPage() async {
    if (isAtEnd) {
      return;
    }
    page++;

    isLoading = true;

    final response = await getData();

    if (data.items.isEmpty) {
      data = response;
    } else {
      data.items.addAll(response.items);
    }

    isLoading = false;

    emitStateChangeForPagination();
  }

  changeSearch(String searchTerm) async {
    isLoading = true;

    // Reset page and set search term
    this.searchTerm = searchTerm;
    page = 1;

    if (searchTerm.isNotEmpty) {
      final response = await getDataOnSearchChange();
      data = response;
    } else {
      final response = await getData();
      data = response;
    }

    isLoading = false;

    emitStateChangeForSearch();
  }

  resetState() async {
    page = 1;

    final response = await getData();

    data = response;

    emitStateChangeForPagination();
  }

  @protected
  Future<BaseMultiPageResponse<TClass>> getData();

  @protected
  Future<BaseMultiPageResponse<TClass>> getDataOnSearchChange();

  @protected
  void emitStateChangeForPagination();

  @protected
  void emitStateChangeForSearch();
}
