import 'package:daily_mobile_app/src/api/api_client.dart';
import 'package:daily_mobile_app/src/domain/entities/tag.dart';
import 'package:daily_mobile_app/src/domain/interfaces/tag_repositoty.dart';

class TagRestRepositoryImpl extends TagRestRepository {
  final ApiClient _apiClient;

  TagRestRepositoryImpl(this._apiClient);

  @override
  Future<List<Tag>> getPopularTags() {
    return Future(() {
      return _apiClient.getPopularTags().then((responses) {
        var result =
            responses.map((response) => Tag(response.name, false)).toList();
        return Future.value(result);
      });
    });
  }

  @override
  Future<List<Tag>> searchTag(String query) {
    return _apiClient.searchTags(query).then((tags) {
      return tags.map((tagResponse) => Tag(tagResponse.name, false)).toList();
    });
  }
}
