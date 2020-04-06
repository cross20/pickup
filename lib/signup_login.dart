//this file contains frontend aspect of the authentication

import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignupLoginPage extends StatefulWidget {

  SignupLoginPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;
 
  @override
  State<StatefulWidget> createState() => new _SignupLoginPageState();

}

class _SignupLoginPageState extends State<SignupLoginPage>{
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isLoginForm = false; //inital state of authentication page is signup form

  String _email;
  String _password;
  String _errorMessage ;

//returns true if form is validated
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

    // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = ""; 
      _isLoading = true;
    });
    if (validateAndSave()) {  //checks if the format of input in form is correct or not
      String userId = ""; //userid returned form signIn/signUp function is stored here
      try {
      
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password); //triggers signIn function if it is login form
          print('Signed in: $userId');
        } 
        else 
        {
          userId = await widget.auth.signUp(_email, _password); //triggers signUp function if it is signup form
          widget.auth.sendEmailVerification();  //displays email verification dialog after user submits signup details
          _showVerifyEmailSentDialog();     
          print('Signed up user: $userId');
        }

        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {//verifies userid returned after login/signup
          widget.loginCallback();  //takes users to the homepage if valid userid is returned
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  //main structure for signup/login page
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter login demo"), //title section of the signup/login page
      ),
      body: Stack(
        children: <Widget>[
          _showForm(),           //displays the forms
        _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }


  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }


void _showVerifyEmailSentDialog() {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       // return object of type Dialog
       return AlertDialog(
         title: new Text("Verify your account"),
         content:
             new Text("Link to verify account has been sent to your email"),
         actions: <Widget>[
           new FlatButton(
             child: new Text("Dismiss"),
             onPressed: () {
               toggleFormMode();
               Navigator.of(context).pop();
             },
           ),
         ],
       );
     },
   );
 }
  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }


  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
           onPressed: validateAndSubmit,
          ),
        ));
  }


  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode); //toggles between login and signup
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm; //makes the state of loginform state opposite
    });
  }

      // display error if input for signup/login is invalid
    Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

//displays the complete form components
  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              //showErrorMessage(),
            ],
          ),
        ));
  }

   void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }
 
}