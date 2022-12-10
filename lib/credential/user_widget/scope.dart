import 'package:flutter/widgets.dart';
import 'package:kite/credential/entity/credential.dart';
import 'package:kite/events/bus.dart';
import 'package:kite/events/events.dart';

import '../entity/user_type.dart';
import '../init.dart';

class AuthScope extends InheritedWidget {
  final OACredential? oaCredential;
  final DateTime? lastOaAuthTime;
  final FreshmanCredential? freshmanCredential;
  final DateTime? lastFreshmanAuthTime;
  final UserType? lastUserType;

  const AuthScope({
    super.key,
    this.oaCredential,
    this.lastOaAuthTime,
    this.freshmanCredential,
    this.lastFreshmanAuthTime,
    this.lastUserType,
    required super.child,
  });

  static AuthScope of(BuildContext context) {
    final AuthScope? result = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(result != null, 'No AuthScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) {
    return oaCredential == oldWidget.oaCredential &&
        lastOaAuthTime == oldWidget.lastOaAuthTime &&
        freshmanCredential == oldWidget.freshmanCredential &&
        lastFreshmanAuthTime == oldWidget.lastFreshmanAuthTime &&
        lastUserType == oldWidget.lastUserType;
  }
}

extension AuthScopeEx on BuildContext {
  AuthScope get auth => AuthScope.of(this);
}

class AuthScopeMaker extends StatefulWidget {
  final Widget child;

  const AuthScopeMaker({super.key, required this.child});

  @override
  State<AuthScopeMaker> createState() => _AuthScopeMakerState();
}

class _AuthScopeMakerState extends State<AuthScopeMaker> {
  @override
  void initState() {
    super.initState();
    On.global<CredentialChangeEvent>((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = CredentialInit.credential;
    return AuthScope(
      oaCredential: storage.oaCredential,
      lastOaAuthTime: storage.lastOaAuthTime,
      freshmanCredential: storage.freshmanCredential,
      lastFreshmanAuthTime: storage.lastFreshmanAuthTime,
      lastUserType: storage.lastUserType,
      child: widget.child,
    );
  }
}
