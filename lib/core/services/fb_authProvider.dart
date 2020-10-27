import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class Fbauth extends ChangeNotifier {
  final facebookLogin = FacebookLogin();
  Geoflutterfire _geo = Geoflutterfire();
  final ImagePicker _picker = ImagePicker();

  FacebookLoginResult result;
  AuthCredential credential;
  User user;
  String _uploadedFileURL;

  bool get isLogin => user?.id != null;
  User get getMe => user;

  Future tryLogin() async {
    print("call try faunction..................................");
    try {
      user = await getUser();
    } catch (e) {
      print(e.toString());
    }
    print(user);
    if (user == null) return false;
    notifyListeners();
  }

  Future getUser() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

    if (firebaseUser == null) {
      return null;
    }
    print(
        firebaseUser.displayName + firebaseUser.email + firebaseUser.photoUrl);
    DocumentSnapshot result = await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .get();
    User tUser;
    try {
      tUser = User.fromJson(result.data);
    } catch (e) {
      print(e.toString());
    }
    return tUser;
  }

  Future fbAuth() async {
    print('fb login loading');
    result = await facebookLogin.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        String token = result.accessToken.token;

        credential = FacebookAuthProvider.getCredential(accessToken: token);

        return "login success";
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancle by user');
        return "login cancle";
        break;
      case FacebookLoginStatus.error:
        print("some error ....... ${result.errorMessage.toString()}");
        return "login error";
        break;
    }
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('cancle by user');
        return "login cancle";
      }

      print(googleUser);
      print(".userrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      print(credential);
      print(".userrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      return "login success";
    } catch (e) {
      print("some error ....... ${result.errorMessage.toString()}");
      return "login error";
    }
  }

  Future initUserData() async {
    AuthResult firebaseUser =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print(firebaseUser.toString());
    print(",,,,,,,,,,,,,,,,,,,,,,,,,,,");

    print(firebaseUser.additionalUserInfo.isNewUser);

    if (firebaseUser.additionalUserInfo.isNewUser) {
      //init user data
      user = User(
          displayName: firebaseUser.user.displayName,
          id: firebaseUser.user.uid,
          email: firebaseUser.user.email ?? '',
          isActive: false,
          rewardAd: 5,
          profilePicture: firebaseUser.user.photoUrl);

      // create user in db
      DocumentReference documentReference =
          Firestore.instance.collection("users").document(user.id);

      GeoFirePoint myLocation =
          _geo.point(latitude: -52.7794887, longitude: 77.3497273);

      List<String> indexes = [''];
      for (int i = 1; i <= user.displayName.length; i++) {
        String subString = user.displayName.substring(0, i).toLowerCase();
        indexes.add(subString);
      }

      Map json = user.toJson();
      json["indexes"] = indexes;
      json['location'] = myLocation.data;
      documentReference.setData(json);
    } else {}

    notifyListeners();
  }

  Future fbLogout() async {
    try {
      await facebookLogin.logOut();
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      result = null;
      user.id = null;
      credential = null;
      notifyListeners();
    } catch (e) {}
  }

  Future uploadFile() async {
    final PickedFile pickedFile = await _picker.getImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 50,
        imageQuality: 50);

    if (pickedFile == null) return;

    var croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 250,
        maxHeight: 250,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));

    if (croppedImage == null) return;

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/${Path.basename(croppedImage.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(croppedImage);
    await uploadTask.onComplete;
    print('File Uploaded');
    String fileURL = await storageReference.getDownloadURL();
    user.profilePicture = fileURL;
    _uploadedFileURL = fileURL;
    DocumentReference documentReference =
        Firestore.instance.collection("users").document(user.id);

    await documentReference.updateData(user.toJson());
    print("end upload");

    return _uploadedFileURL;
  }

  Future updateUserInfo(
      String name, String email, String phone, String social) async {
    DocumentReference documentReference =
        Firestore.instance.collection("users").document(user.id);

    user.displayName = name;
    user.email = email;
    user.phone = phone;
    user.social = social;

    List<String> indexes = [''];
    for (int i = 1; i <= user.displayName.length; i++) {
      String subString = user.displayName.substring(0, i).toLowerCase();
      indexes.add(subString);
    }

    Map json = user.toJson();
    json["indexes"] = indexes;

    await documentReference.updateData(json);
  }

  Future updateUserReward() async {
    DocumentReference documentReference =
        Firestore.instance.collection("users").document(user.id);

    await documentReference.updateData(user.toJson());
  }
}
