import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/common/enums/message_enum.dart';
import 'package:chat_app/features/chat/widgets/video_player_item.dart';
import 'package:flutter/widgets.dart';

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
    return msgType == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
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
