import 'package:daily_mobile_app/src/domain/entities/tag.dart';
import 'package:daily_mobile_app/src/domain/interfaces/tag_repositoty.dart';

class TagService {
  final TagRestRepository _tagRestRepository;
  final TagStorageRepository _tagStorageRepository;

  TagService(this._tagRestRepository, this._tagStorageRepository);

  List<Tag> tags;
  Set<Tag> selectedTags;
  bool needShowExplanation = true;

  void initState() async {
    final restTags = await _tagRestRepository.getPopularTags();
    selectedTags = await _tagStorageRepository.getSelectedTags().then((tags) {
      return Future.value(tags.toSet());
    });
    tags = await _mergeWithSelected(restTags, selectedTags.toList());
  }

  void loadTags([String searchQuery]) async {
    List<Tag> restTags;
    if (searchQuery == null || searchQuery.isEmpty) {
      restTags = await _tagRestRepository.getPopularTags();
      needShowExplanation = true;
    } else {
      restTags = await _tagRestRepository.searchTag(searchQuery);
      needShowExplanation = false;
    }
    tags = await _mergeWithSelected(restTags, selectedTags.toList());
  }

  void onTagClick(String text, bool isChecked) async {
    return Future<void>(() {
      final tagText = text.replaceFirst('#', '');
      if (isChecked) {
        var selectedTag = Tag(tagText, true);
        selectedTags.add(selectedTag);
        return _tagStorageRepository.addSelectedTag(selectedTag);
      } else {
        Tag needDelete;
        selectedTags.forEach((tag) {
          if (tag.text == tagText) {
            needDelete = tag;
          }
        });
        if (needDelete != null) {
          selectedTags.remove(needDelete);
        }
        return needDelete != null
            ? _tagStorageRepository.removeSelectedTag(needDelete)
            : Future.value();
      }
    });
  }

  Future<List<Tag>> _mergeWithSelected(
      List<Tag> tags, List<Tag> selectedTags) async {
    return Future<List<Tag>>(() {
      List<Tag> result = List();
      tags.forEach((tag) {
        final tagInSelected = selectedTags.find(tag);
        result.add(tagInSelected != null ? Tag(tagInSelected.text, true) : tag);
      });
      return Future.value(result);
    });
  }
}

extension _Tags on List<Tag> {
  Tag find(Tag tag) {
    final index = this.indexWhere((searchTag) => searchTag.text == tag.text);
    return index != -1 ? this[index] : null;
  }
}
