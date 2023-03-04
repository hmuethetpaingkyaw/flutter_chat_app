import 'dart:io';

import 'package:chat_app/widgets/pickers/user_image_picker.dart';

import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(String email, String password, String username,
      File image, bool isLogin, BuildContext ctx) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  var _isLogin = true;
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Plz pick an image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail, _userPassword, _userName,
          _userImageFile as File, _isLogin, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            if (!_isLogin) UserImagePicker(imagePickFn: _pickedImage),
            TextFormField(
              validator: ((value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              }),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email Address'),
              onSaved: (value) {
                _userEmail = '$value';
              },
            ),
            if (!_isLogin)
              TextFormField(
                key: ValueKey('username'),
                autocorrect: true,
                textCapitalization: TextCapitalization.words,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) {
                  _userName = '$value';
                },
              ),
            TextFormField(
              validator: ((value) {
                if (value!.isEmpty || value.length < 7) {
                  return 'Please enter a valid password';
                }
                return null;
              }),
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onSaved: (value) {
                _userPassword = '$value';
              },
            ),
            SizedBox(
              height: 12,
            ),
            if (widget.isLoading) CircularProgressIndicator(),
            if (!widget.isLoading)
              RaisedButton(
                onPressed: trySubmit,
                child: _isLogin ? const Text('Login') : const Text('SignUp'),
              ),
            if (!widget.isLoading)
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(_isLogin
                    ? 'Create new account'
                    : 'I already have an account'),
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
              )
          ]),
        ),
      )),
    ));
  }
}
