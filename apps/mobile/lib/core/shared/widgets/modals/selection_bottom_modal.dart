import 'package:flutter/material.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/shared/models/dropdowns/base_dropdown_item.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// A bottom sheet listing [items] for the user to pick one from — used by
/// "Add product" / "Select client" style pickers. Pop it with
/// showModalBottomSheet(builder: (_) => SelectionBottomModal(...)).
class SelectionBottomModal extends StatelessWidget {
  final List<BaseDropdownItem> items;
  final String title;
  final ValueChanged<BaseDropdownItem> onItemSelected;

  const SelectionBottomModal({
    super.key,
    required this.items,
    required this.title,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Container(
        decoration: BoxDecoration(
          color: theme.baseWhite,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(color: theme.primaryText, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: const EdgeInsets.all(4),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: theme.primaryText.withValues(alpha: 0.05), shape: BoxShape.circle),
                        child: Icon(Icons.close, color: theme.primaryText.withValues(alpha: 0.9), size: 18),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.primaryText.withValues(alpha: 0.05)),
            Flexible(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          TranslationStorage.translation.noItemsAvailable,
                          style: TextStyle(fontSize: 14, color: theme.primaryText.withValues(alpha: 0.5)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(
                            item.text,
                            style: TextStyle(fontSize: 15, color: theme.primaryText, fontWeight: FontWeight.w500),
                          ),
                          subtitle: item.subtitle != null
                              ? Text(item.subtitle!, style: TextStyle(fontSize: 13, color: theme.primaryText.withValues(alpha: 0.5)))
                              : null,
                          onTap: () {
                            onItemSelected(item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
