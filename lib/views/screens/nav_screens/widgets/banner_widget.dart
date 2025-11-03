import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mac_store_app_new/controllers/BannerController.dart';
import 'package:mac_store_app_new/models/banner_model.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late Future<List<BannerModel>> banners;
  final BannerController _bannerController = BannerController();
  @override
  // Tạo initState để load banners tự động khi vào trang Banner
  void initState() {
    super.initState();
    banners = _bannerController.loadBanners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: banners,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncSnapshot.hasError) {
          return Center(child: Text('Error: ${asyncSnapshot.error}'));
        }
        if (asyncSnapshot.hasData && asyncSnapshot.data!.isNotEmpty) {
          final data = asyncSnapshot.data!;
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                aspectRatio: 2048 / 1150,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOut,
              ),
              items: data.map((item) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(item.image, fit: BoxFit.cover),
                );
              }).toList(),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
