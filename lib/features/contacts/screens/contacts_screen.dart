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
    ref.read(contactControllerProvider).selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
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
      body: FutureBuilder<List<Contact>>(
        future: ref.read(contactControllerProvider).getAllContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const ErrorScreen(error: 'Failed to load contacts');
          }
          final contactList = snapshot.data;
          return ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => selectContact(ref, contactList[index], context),
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
            itemCount: contactList!.length,
          );
        },
      ),
    );
  }
}
