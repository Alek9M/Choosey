import 'dart:async';
import 'dart:developer';
import 'package:choosey/profile.dart';
import 'package:choosey/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> scopes = <String>[
  'email',
];

// String clientId = const String.fromEnvironment('CLIENT_ID');//dotenv.env['CLIENT_ID'],

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: googleClientId,
  scopes: scopes,
);


class SignIn extends StatefulWidget {

  const SignIn({super.key});

  @override
  State createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
          print("Listening");

      bool isAuthorized =
          account != null && await _googleSignIn.canAccessScopes(scopes);

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });
      print("Set state");

      // if (isAuthorized) {
      // }
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }


  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    // #enddocregion RequestScopes
    setState(() {
      _isAuthorized = isAuthorized;
    });
    // if (isAuthorized) {
    //   unawaited(_handleGetContact(_currentUser!));
    // }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      // return
        // Profile(user: user!);
        return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          if (_isAuthorized) ...<Widget>[
            Text("_contactText"),
          ],
          if (!_isAuthorized) ...<Widget>[
            const Text('Additional permissions needed.'),
            ElevatedButton(
              onPressed: _handleAuthorizeScopes,
              child: const Text('REQUEST PERMISSIONS'),
            ),
          ],
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Please sign in'),
          ElevatedButton(
            onPressed: _handleSignIn,
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),

            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/sign_in.svg',
                  height: 80,
                  width: 80,
                ),
              ],
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Choosey'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
