import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/common/enums/message_enum.dart';
import 'package:chat_app/features/chat/widgets/video_player_item.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MessageType extends StatelessWidget {
  final String message;
  final MessageEnum msgType;

  const MessageType({
    Key? key,
    required this.message,
    required this.msgType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    return msgType == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : msgType == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.play(UrlSource(message));
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                );
              })
            : msgType == MessageEnum.video
                ? VideoPlayerItem(
                    videoUrl: message,
                  )
                : msgType == MessageEnum.gif
                    ? CachedNetworkImage(
                        imageUrl: message,
                      )
                    : CachedNetworkImage(
                        imageUrl: message,
                      );
  }
}
