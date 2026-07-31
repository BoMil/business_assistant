import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:business_assistant/config/environment/environment.dart';
import 'package:business_assistant/core/shared/widgets/dropdowns/location_auto_complete_menu.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/input_styles.dart';

/// The address + coordinates chosen from a LocationInputField search.
class LocationOutput {
  final String address;
  final double? latitude;
  final double? longitude;

  const LocationOutput({required this.address, this.latitude, this.longitude});
}

/// A single Google Places autocomplete suggestion.
class LocationPrediction {
  final String description;
  final String placeId;

  const LocationPrediction({required this.description, required this.placeId});
}

/// Address search field backed by the Google Places Autocomplete API.
///
/// Requires Environment.googlePlacesApiKey to be set (see .env/<tenant>.<environment>.json,
/// GOOGLE_PLACES_API_KEY) — without a real key, Google's API will reject the requests.
///
/// Built directly on Flutter's RawAutocomplete instead of the google_places_flutter
/// package: that package recreated its FocusNode on every keystroke (which ate
/// backspace input) and never closed its suggestion overlay on focus loss.
/// RawAutocomplete handles both correctly.
class LocationInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String hintText;
  final ValueChanged<LocationOutput> onLocationSelected;
  final String? errorMsg;

  /// Language for Places API results (e.g. 'en', 'sr') — see
  /// https://developers.google.com/maps/faq#languagesupport for supported codes.
  /// Omit to let Google infer it from the request.
  final String? language;

  const LocationInputField({
    super.key,
    required this.controller,
    required this.onLocationSelected,
    this.labelText,
    this.hintText = '',
    this.errorMsg,
    this.language,
  });

  @override
  State<LocationInputField> createState() => _LocationInputFieldState();
}

class _LocationInputFieldState extends State<LocationInputField> {
  final Dio _dio = Dio();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<Iterable<LocationPrediction>> _search(TextEditingValue value) async {
    final input = value.text.trim();
    if (input.isEmpty) return const [];

    // Debounce: wait for typing to settle before hitting the API. If a newer
    // keystroke cancels this timer, this call's completer never resolves —
    // RawAutocomplete only acts on the latest optionsBuilder call anyway.
    _debounce?.cancel();
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 500), completer.complete);
    await completer.future;

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': Environment.googlePlacesApiKey,
          if (widget.language != null) 'language': widget.language,
        },
      );
      final predictions = response.data['predictions'] as List? ?? [];
      return predictions
          .map(
            (json) => LocationPrediction(
              description: json['description'] as String? ?? '',
              placeId: json['place_id'] as String? ?? '',
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('LocationInputField autocomplete error: $e');
      return const [];
    }
  }

  Future<void> _selectPrediction(LocationPrediction prediction) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {'place_id': prediction.placeId, 'fields': 'geometry', 'key': Environment.googlePlacesApiKey},
      );
      final location = response.data['result']?['geometry']?['location'];
      widget.onLocationSelected(
        LocationOutput(
          address: prediction.description,
          latitude: (location?['lat'] as num?)?.toDouble(),
          longitude: (location?['lng'] as num?)?.toDouble(),
        ),
      );
    } catch (e) {
      debugPrint('LocationInputField place details error: $e');
      widget.onLocationSelected(LocationOutput(address: prediction.description));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[InputLabel(text: widget.labelText!), const SizedBox(height: 4)],
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<LocationPrediction>(
              textEditingController: widget.controller,
              focusNode: _focusNode,
              optionsBuilder: _search,
              displayStringForOption: (option) => option.description,
              onSelected: _selectPrediction,
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputStyles.primaryInputDecoration(
                    hintText: widget.hintText,
                    fillColor: theme.baseWhite,
                    borderColor: theme.primaryText.withValues(alpha: 0.15),
                    prefixIcon: Icon(Icons.location_on_outlined, color: theme.primaryText.withValues(alpha: 0.5)),
                    suffix:
                        textController.text.isEmpty
                            ? null
                            : IconButton(
                              icon: Icon(Icons.close, color: theme.primaryText.withValues(alpha: 0.5)),
                              onPressed: textController.clear,
                            ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: constraints.maxWidth,
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        color: theme.baseWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.primaryText.withValues(alpha: 0.15)),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: LocationAutoCompleteMenu(prediction: option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (widget.errorMsg != null) ...[
          const SizedBox(height: 4),
          Text(widget.errorMsg!, style: TextStyle(color: theme.brandError, fontSize: 13, fontWeight: FontWeight.w400)),
        ],
      ],
    );
  }
}
