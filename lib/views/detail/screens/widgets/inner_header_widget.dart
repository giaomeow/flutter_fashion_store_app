import 'package:flutter/material.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/search_bar_widget.dart';

class InnerHeaderWidget extends StatelessWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchClear;
  final Function(String)? onSearchSubmitted;

  const InnerHeaderWidget({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClear,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo controller mặc định nếu không được cung cấp
    final controller = searchController ?? TextEditingController();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.18,
      child: Stack(
        children: [
          // Background banner
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.18,
            child: Image(
              image: const AssetImage('assets/icons/searchBanner.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          // Search bar overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SearchBarWidget(
              controller: controller,
              onChanged: onSearchChanged,
              onClear: onSearchClear,
              onSubmitted: onSearchSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
