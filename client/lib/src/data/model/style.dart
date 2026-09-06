class ModelStyle {
  final String id;
  final String name;
  final String slug;
  final String image_name;

  const ModelStyle({
    this.id = '',
    this.name = '',
    this.slug = '',
    this.image_name = '',
  });

  static ModelStyle fromJson(Map<String, dynamic> json) => ModelStyle(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        image_name: json['image_name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'image_name': image_name,
      };
}
