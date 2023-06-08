import 'package:chat_app/features/chat/widgets/message_type.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../common/enums/message_enum.dart';
import '../../../common/utils/color.dart';

class MessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum msgType;
  final VoidCallback onLeftSwipe;
  final String repliedTextMessage;
  final String username;
  final MessageEnum repliedMessageType;
  final bool isSeen;

  const MessageCard(
      {Key? key,
      required this.message,
      required this.date,
      required this.msgType,
      required this.onLeftSwipe,
      required this.repliedTextMessage,
      required this.username,
      required this.repliedMessageType,
      required this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedTextMessage.isNotEmpty;

    return SwipeTo(
      onLeftSwipe: onLeftSwipe,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                    padding: msgType == MessageEnum.text
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 30,
                            top: 5,
                            bottom: 20,
                          )
                        : const EdgeInsets.only(
                            left: 5,
                            top: 5,
                            bottom: 25,
                            right: 5,
                          ),
                    child: Column(
                      children: [
                        if (isReplying) ...[
                          Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  5,
                                ),
                              ),
                            ),
                            child: MessageType(
                              message: repliedTextMessage,
                              msgType: repliedMessageType,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        MessageType(
                          message: message,
                          msgType: msgType,
                        ),
                      ],
                    )),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        isSeen ? Icons.done_all : Icons.done,
                        size: 20,
                        color: isSeen ? Colors.blue : Colors.white60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
