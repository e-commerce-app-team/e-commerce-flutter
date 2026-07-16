import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

/// Handles API calls related to staff invitation acceptance.
class StaffInviteData {
  final Crud crud;
  StaffInviteData(this.crud);

  /// Called when a staff member clicks the invitation link in their email.
  /// They provide the [invitationToken] from the link, plus a new [password].
  Future<dynamic> acceptInvite({
    required String invitationToken,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirmation,
  }) async =>
      await crud.postData(
        AppLink.staffAcceptInvite,
        {
          'token':                 invitationToken,
          'first_name':            firstName,
          'last_name':             lastName,
          'password':              password,
          'password_confirmation': passwordConfirmation,
        },
      );
}
