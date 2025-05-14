import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/core/enum/page_status.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'dart:convert';

class NewsPageController extends GetxController {
  ArticlesApiProvider articlesApiProvider = Get.find();
  FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  final RxnString rxnNewLiveUrl = RxnString();
  final RxList rxLiveCamList = RxList();
  final RxBool rxIsElectionShow = false.obs;
  final RxBool rxIsBannerShow = false.obs;
  final RxMap<String, dynamic> rxBannerData = <String, dynamic>{}.obs;
  final RxList<StoryListItem> rxEditorChoiceList = RxList();
  final RxList<StoryListItem> rxRenderStoryList = RxList();
  final List<int> articleInsertIndexArray = [4, 6, 9, 11];
  int page = 0;
  final int articleDefaultCountOnePage = 20;
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  final Rx<PageStatus> rxPageStatus = PageStatus.loading.obs;

  @override
  void onInit() async {
    super.onInit();
    await firebaseRemoteConfig.fetchAndActivate();
    rxIsElectionShow.value = firebaseRemoteConfig.getBool('isElectionShow');
    rxIsBannerShow.value = firebaseRemoteConfig.getBool('isBannerShow');
    String? bannerJsonString = firebaseRemoteConfig.getString('BannerURL');
    if (bannerJsonString.isNotEmpty) {
      try {
        rxBannerData.assignAll(jsonDecode(bannerJsonString));
      } catch (e) {
        rxBannerData.clear();
      }
    } else {
      rxBannerData.clear();
    }
    rxnNewLiveUrl.value = await articlesApiProvider.getNewsLiveUrl();
    rxLiveCamList.value = await articlesApiProvider.getLiveCamUrlList();
    rxEditorChoiceList.value =
        await articlesApiProvider.fetchEditorChoiceList();
    fetchArticleList();
    scrollController.addListener(scrollEvent);
  }

  void scrollEvent() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchMoreArticle();
    }
  }

  void fetchArticleList() async {
    rxPageStatus.value = PageStatus.loading;
    page = 0;

    try {
      final results = await Future.wait([
        articlesApiProvider.getLatestArticles(
            skip: 0, first: articleDefaultCountOnePage),
        articlesApiProvider.getExternalArticlesList(
            skip: 0, first: articleDefaultCountOnePage),
      ]);

      final List<StoryListItem> posts = results[0];
      final List<StoryListItem> externals = results[1];

      List<StoryListItem> combinedList = [];
      combinedList.addAll(posts);
      combinedList.addAll(externals);

      combinedList.sort((a, b) {
        if (a.publishTime == null && b.publishTime == null) return 0;
        if (a.publishTime == null) return 1;
        if (b.publishTime == null) return -1;
        return b.publishTime!.compareTo(a.publishTime!);
      });

      List<StoryListItem> salesArticles = [];
      try {
        salesArticles = await articlesApiProvider.getSalesArticles();
      } catch (e) {
        // error
      }

      final List<StoryListItem> allArticles = [
        ...combinedList,
        ...salesArticles
      ];

      List<StoryListItem> uniqueArticles = [];
      Set<String?> uniqueSlugs = {};
      for (var article in allArticles) {
        if (uniqueSlugs.add(article.slug)) {
          uniqueArticles.add(article);
        }
      }

      rxRenderStoryList.value = uniqueArticles;

      if (uniqueArticles.length < articleDefaultCountOnePage &&
          posts.length < articleDefaultCountOnePage &&
          externals.length < articleDefaultCountOnePage) {
        rxPageStatus.value = PageStatus.loadingEnd;
      } else {
        rxPageStatus.value = PageStatus.normal;
      }
    } catch (e) {
      rxPageStatus.value = PageStatus.error;
    }
  }

  void fetchMoreArticle() async {
    if (rxPageStatus.value == PageStatus.loading ||
        rxPageStatus.value == PageStatus.loadingEnd) {
      return;
    }
    rxPageStatus.value = PageStatus.loading;
    page++;

    try {
      final results = await Future.wait([
        articlesApiProvider.getLatestArticles(
            skip: page * articleDefaultCountOnePage,
            first: articleDefaultCountOnePage),
        articlesApiProvider.getExternalArticlesList(
            skip: page * articleDefaultCountOnePage,
            first: articleDefaultCountOnePage),
      ]);

      final List<StoryListItem> newPosts = results[0];
      final List<StoryListItem> newExternals = results[1];

      bool noMoreNewPosts = newPosts.isEmpty;
      bool noMoreNewExternals = newExternals.isEmpty;

      if (noMoreNewPosts && noMoreNewExternals) {
        rxPageStatus.value = PageStatus.loadingEnd;
        return;
      }

      List<StoryListItem> currentList = List.from(rxRenderStoryList);
      currentList.addAll(newPosts);
      currentList.addAll(newExternals);

      currentList.sort((a, b) {
        if (a.publishTime == null && b.publishTime == null) return 0;
        if (a.publishTime == null) return 1;
        if (b.publishTime == null) return -1;
        return b.publishTime!.compareTo(a.publishTime!);
      });

      Set<StoryListItem> uniqueObjects = Set<StoryListItem>.from(currentList);
      rxRenderStoryList.value = uniqueObjects.toList();

      if (noMoreNewPosts &&
          noMoreNewExternals &&
          rxRenderStoryList.length == currentList.length / 2) {
      } else {
        rxPageStatus.value = PageStatus.normal;
      }
    } catch (e) {
      print("Error fetching more articles: $e");
      rxPageStatus.value = PageStatus.error;
    }
  }
}
