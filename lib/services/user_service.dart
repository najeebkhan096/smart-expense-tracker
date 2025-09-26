import 'package:cloud_firestore/cloud_firestore.dart';
import '../modal/user_modal.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update a user in Firestore
  Future<void> saveUser({required AppUser user}) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(
        user.toJson(),
        SetOptions(merge: true), // merge to update last login
      );
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      print('FirebaseException in saveUser: ${e.message}');
      rethrow;
    } catch (e) {
      // Handle any other errors
      print('Error in saveUser: $e');
      rethrow;
    }
  }

  /// Get user by UID
  Future<AppUser?> getUser({required String uid}) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(json: doc.data()!, id: doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      print('FirebaseException in getUser: ${e.message}');
      return null;
    } catch (e) {
      print('Error in getUser: $e');
      return null;
    }
  }
}
