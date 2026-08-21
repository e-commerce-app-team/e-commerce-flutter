import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatConversationId {
  const ChatConversationId._();

  static String forUsers({required int sellerId, required int buyerId}) =>
      'chat_${sellerId}_$buyerId';
}

class ChatService {
  const ChatService._();

  static DocumentReference<Map<String, dynamic>> conversationRef({
    required int sellerId,
    required int buyerId,
  }) => FirebaseFirestore.instance
      .collection('conversations')
      .doc(ChatConversationId.forUsers(sellerId: sellerId, buyerId: buyerId));

  static String uidFor(int id) => id.toString();

  static Future<void> ensureFirebaseAuth({
    required String token,
    required Future<String?> Function(String token) fetchCustomToken,
    required String expectedUserId,
  }) async {
    if (token.isEmpty || expectedUserId.isEmpty) {
      throw StateError('Chat authentication requires a valid API session.');
    }

    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser?.uid == expectedUserId) return;
    if (currentUser != null) await auth.signOut();

    final customToken = await fetchCustomToken(token);
    if (customToken == null || customToken.isEmpty) {
      throw StateError(
        'The chat server did not return a Firebase custom token.',
      );
    }
    final credential = await auth.signInWithCustomToken(customToken);
    if (credential.user?.uid != expectedUserId) {
      await auth.signOut();
      throw StateError('Firebase UID does not match the application user ID.');
    }
  }
}

