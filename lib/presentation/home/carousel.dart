import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Carousel extends StatelessWidget {
  const Carousel({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              image: NetworkImage(imageUrl),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final carouselIndex = 0.obs;

  void updatePageIndicator(index) {
    carouselIndex.value = index;
  }
}

class CarouselSlidebar extends StatelessWidget {
  const CarouselSlidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
            items: const [
              Carousel(
                  imageUrl:
                      "https://cdn.pixabay.com/photo/2021/08/25/20/42/field-6574455_640.jpg"),
              Carousel(
                  imageUrl:
                      "https://next-images.123rf.com/index/_next/image/?url=https://assets-cdn.123rf.com/index/static/assets/top-section-bg.jpeg&w=3840&q=75"),
              Carousel(
                  imageUrl:
                      "https://thumbs.dreamstime.com/b/magnifique-paysage-de-coucher-soleil-avec-montagnes-et-rivi%C3%A8re-d-rendu-g%C3%A9n%C3%A9ratif-ai-fantastique-vue-arbres-313450140.jpg"),
            ],
            options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1,
                onPageChanged: (index, _) {
                  return controller.updatePageIndicator(index);
                })),
        Obx(
          () => Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Circlecontainer(
                      background: controller.carouselIndex.value == i
                          ? const Color(0xff263eb8)
                          : Colors.white)
              ],
            ),
          ),
        )
      ],
    );
  }
}

class Circlecontainer extends StatelessWidget {
  const Circlecontainer({
    super.key,
    required this.background,
  });
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
        ),
      ),
    );
  }
}
