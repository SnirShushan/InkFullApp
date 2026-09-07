import 'package:ink/src/data/model/post_inspiration_model.dart';

class HomePostsResponse {
  final Map<String, List<PostInspirationModel>> postInspirationModel;

  HomePostsResponse({required this.postInspirationModel});

  factory HomePostsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']?['posts'] as Map<String, dynamic>? ?? {};
    final Map<String, List<PostInspirationModel>> parsed = {};

    data.forEach((key, value) {
      final list = (value as List<dynamic>?)
          ?.map((e) => PostInspirationModel.fromJson(e))
          .toList() ??
          [];
      parsed[key] = list;
    });

    return HomePostsResponse(postInspirationModel: parsed);
  }
}