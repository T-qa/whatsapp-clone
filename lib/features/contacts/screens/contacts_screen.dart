import 'package:chat_app/common/widgets/loader.dart';
import 'package:chat_app/features/contacts/controller/contact_controller.dart';
import 'package:chat_app/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactScreen extends ConsumerWidget {
  static const routeName = '/select-contact';
  const ContactScreen({super.key});

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Selec contact'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        body: ref.watch(getContactProvider).when(
              data: (contactList) => ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () =>
                        selectContact(ref, contactList[index], context),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          contactList[index].displayName,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: contactList[index].photo == null
                            ? null
                            : CircleAvatar(
                                backgroundImage:
                                    MemoryImage(contactList[index].photo!),
                                radius: 30,
                              ),
                      ),
                    ),
                  );
                },
                itemCount: contactList.length,
              ),
              error: (error, trace) => ErrorScreen(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ));
  }
}
