import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function() onSearchChanged;
  final Function() onSearchClear;

  const StoreHeaderWidget({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.18,
      child: Stack(
        children: [
          // Background image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.18,
            child: Image(
              image: const AssetImage('assets/icons/searchBanner.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          // Search bar and filters overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: GoogleFonts.quicksand(
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchController,
                        builder: (context, value, child) {
                          return value.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: onSearchClear,
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.quicksand(),
                    onChanged: (value) {
                      onSearchChanged();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Filter tabs (bên phải)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFilterTab(
                            label: 'New',
                            isSelected: selectedFilter == 'New',
                            onTap: () => onFilterChanged('New'),
                          ),
                          _buildFilterTab(
                            label: 'Popular',
                            isSelected: selectedFilter == 'Popular',
                            onTap: () => onFilterChanged('Popular'),
                          ),
                          _buildFilterTab(
                            label: 'Recommend',
                            isSelected: selectedFilter == 'Recommend',
                            onTap: () => onFilterChanged('Recommend'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
