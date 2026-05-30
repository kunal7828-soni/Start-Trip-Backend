import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/maps_state_providers.dart';

/// Highly interactive, modern floating search bar matching premium travel UX guidelines.
/// Triggers reactive autocomplete requests and shows a gorgeous selection dropdown overlay.
class FloatingSearchBar extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;
  final Function(LatLng)? onLocationSelected;

  const FloatingSearchBar({
    super.key,
    this.onBackTap,
    this.onLocationSelected,
  });

  @override
  ConsumerState<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends ConsumerState<FloatingSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showOverlay = _focusNode.hasFocus;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        ref.read(mapsStateProvider.notifier).searchAutocomplete(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapsStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Synchronize external changes to destination name if any
    if (state.destinationName == null && _searchController.text.isNotEmpty && !_focusNode.hasFocus) {
      _searchController.clear();
    } else if (state.destinationName != null &&
        _searchController.text != state.destinationName &&
        !_focusNode.hasFocus) {
      _searchController.text = state.destinationName!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Search Bar Card
        Card(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(isDark ? 0.35 : 0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: isDark ? AppColors.cardDark.withOpacity(0.95) : Colors.white.withOpacity(0.95),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              children: [
                // Back Button or Search Icon
                IconButton(
                  icon: Icon(
                    widget.onBackTap != null ? Icons.arrow_back : Icons.search,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    if (widget.onBackTap != null) {
                      widget.onBackTap!();
                    } else if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                    }
                  },
                ),

                // Main input field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search hotels, railway, destination...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),

                // Actions: Loading spinner or Clean text trigger
                if (state.isSearching)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                else if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white60 : Colors.black45, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(mapsStateProvider.notifier).clearAutocomplete();
                      ref.read(mapsStateProvider.notifier).clearActiveRoute();
                      _focusNode.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),

        // 2. Dropdown Autocomplete Overlay
        if (_showOverlay && state.searchPredictions.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark.withOpacity(0.98) : Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.searchPredictions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                itemBuilder: (context, index) {
                  final prediction = state.searchPredictions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      radius: 16,
                      child: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    ),
                    title: Text(
                      prediction.mainText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      prediction.secondaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      _searchController.text = prediction.mainText;
                      _focusNode.unfocus();
                      setState(() {
                        _showOverlay = false;
                      });
                      
                      // Notify notifier state changes
                      await ref.read(mapsStateProvider.notifier).selectDestination(prediction);

                      if (widget.onLocationSelected != null) {
                        final destLatLng = ref.read(mapsStateProvider).destinationLocation;
                        if (destLatLng != null) {
                          widget.onLocationSelected!(destLatLng);
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
