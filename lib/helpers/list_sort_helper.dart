import 'package:tv/models/storyListItem.dart';

void sortByPublishTime(List<StoryListItem> list) {
  list.sort((a, b) {
    if (a.publishTime == null && b.publishTime == null) return 0;
    if (a.publishTime == null) return 1;
    if (b.publishTime == null) return -1;
    return b.publishTime!.compareTo(a.publishTime!);
  });
}
