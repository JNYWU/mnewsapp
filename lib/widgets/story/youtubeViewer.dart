import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeViewer extends StatefulWidget {
  final String videoID;
  final bool autoPlay;
  final bool mute;
  final Function()? whenFinished;
  YoutubeViewer(
    this.videoID, {
    this.autoPlay = false,
    this.mute = false,
    this.whenFinished,
  });

  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer>
    with AutomaticKeepAliveClientMixin {
  // ignore: close_sinks
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Future<bool> _configChewieFuture;
  var yt = YoutubeExplode();
  bool isInitialized = false;
  bool isFinished = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _configChewieFuture = _configVideoPlayer();
    super.initState();
  }

  Future<bool> _configVideoPlayer() async {
    try {
      // Get youtube video url with higest resolution.
      // Highest resolution is 720P
      // Only use this for get not live video
      var manifest = await yt.videos.streamsClient.getManifest(widget.videoID);
      var streamInfo = manifest.muxed.withHighestBitrate();
      String videoUrl = streamInfo.url.toString();
      _videoPlayerController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        autoPlay: widget.autoPlay,
        showOptions: false,
      );
      if (widget.mute) _chewieController.setVolume(0.0);
      if (widget.whenFinished != null) {
        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.position ==
              _videoPlayerController.value.duration) {
            if (!isFinished) {
              widget.whenFinished!();
              isFinished = true;
            }
          }
        });
      }
    } catch (e) {
      print('Youtube player error: $e');
      return false;
    }
    isInitialized = true;
    return true;
  }

  @override
  void dispose() {
    yt.close();
    if (isInitialized) {
      _videoPlayerController.dispose();
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
      future: _configChewieFuture,
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (snapshot.data == null) {
              return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / (16 / 9),
                  child: Center(child: CircularProgressIndicator()));
            }

            if (!snapshot.data!) {
              return Container();
            }

            Widget _videoPlayer = Chewie(
              controller: _chewieController,
            );

            if (Platform.isAndroid) {
              _videoPlayer = Theme(
                data: ThemeData.light().copyWith(
                  platform: TargetPlatform.windows,
                ),
                child: Chewie(
                  controller: _chewieController,
                ),
              );
            }

            return VisibilityDetector(
              key: UniqueKey(),
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxWidth /
                    _videoPlayerController.value.aspectRatio,
                child: _videoPlayer,
              ),
              onVisibilityChanged: (visibility) {
                if (visibility.visibleFraction == 0) {
                  _chewieController.pause();
                }
              },
            );
          },
        );
      },
    );
  }
}
