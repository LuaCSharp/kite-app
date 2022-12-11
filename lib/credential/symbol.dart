import 'delegate.dart';

import 'dao/credential.dart';
import 'init.dart';

export 'entity/credential.dart';
export 'entity/user_type.dart';
export 'page/unauth.dart';
export 'utils.dart';

// ignore: non_constant_identifier_names
CredentialDao get Auth => CredentialDelegate(CredentialInit.credential);
