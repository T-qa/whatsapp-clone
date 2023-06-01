import 'package:chat_app/features/contacts/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getContactProvider = FutureProvider((ref) {
  final contactRepository = ref.watch(contactRepositoryProvider);
  return contactRepository.getContact();
});

final selectContactControllerProvider = Provider((ref) {
  final contactRepository = ref.watch(contactRepositoryProvider);
  return ContactController(
    ref: ref,
    contactRepository: contactRepository,
  );
});

class ContactController {
  final ProviderRef ref;
  final ContactRepository contactRepository;

  ContactController({
    required this.ref,
    required this.contactRepository,
  });

  void selectContact(Contact selectedContact, BuildContext context) {
    contactRepository.selectContact(selectedContact, context);
  }
}
