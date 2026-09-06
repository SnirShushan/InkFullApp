
enum ImageSourceType {
  file,
  url,
}

class MultiPostSlider {
  final String imageName;
  final ImageSourceType imageType;

  MultiPostSlider({
    required this.imageName,
    required this.imageType,
  });
}


