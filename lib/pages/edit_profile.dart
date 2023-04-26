import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/account.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/resources/storage_methods.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:intl/intl.dart';
import 'package:howl/widgets/intl_phone_field.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({this.user});
  @override
  _EditProfileStatePage createState() => _EditProfileStatePage();
}

class _EditProfileStatePage extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  StorageMethods _storageMethods = StorageMethods();
  File _profileImage;
  String name;
  String username;
  String email;
  String birthdate;
  String bio;
  String gender;
  String profileUrl;
  bool _submitting = false;

  String deactivateString;

  void _submit() async {
    setState(() {
      _submitting = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (_profileImage == null) {
        profileUrl = widget.user.profileUrl;
      } else {
        profileUrl = await _storageMethods.uploadProfileImage(
            widget.user.profileUrl, _profileImage, widget.user.username);
      }
      User user = User(
        id: widget.user.id,
        name: name,
        username: username,
        bio: bio,
        birthdate: birthdate,
        email: email,
        gender: gender,
        profileUrl: profileUrl,
      );
      await _firebaseMethods.updateUser(user);
      setState(() {
        _submitting = false;
      });
      Navigator.pop(context);
    } else {
      setState(() {
        _submitting = false;
      });
      print('Is not Submitting');
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    name = widget.user.name;
    username = widget.user.username;
    bio = widget.user.bio;
    email = widget.user.email;
    birthdate = widget.user.birthdate;
    gender = widget.user.gender;
    profileUrl = widget.user.profileUrl;
    _submitting = false;

    super.initState();
  }

  _showSelectPhotoDialog() {
    return Platform.isIOS ? _showIOSDialog() : _showAndroidDialog();
  }

  _showIOSDialog() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('Upload Profile Photo'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('Choose From Gallery'),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
              CupertinoActionSheetAction(
                child: Text('Take a Photo'),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              CupertinoActionSheetAction(
                child: Text('Remove Existing Photo'),
                onPressed: () => _removeImage(),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _showAndroidDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Select a Photo',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'New Photo From Gallery',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Take a Photo',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  child: Text(
                    'Remove Existing Photo',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => _removeImage(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: SimpleDialogOption(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .apply(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          );
        });
  }

  _handleImage(ImageSource source) async {
    XFile imageFile = await ImagePicker().pickImage(source: source);
    if (imageFile != null) {
      imageFile = await _imageCrop(imageFile as File);
      setState(() {
        _profileImage = imageFile as File;
      });
    }
    Navigator.pop(context);
  }

  _removeImage() async {
    _profileImage = null;
    Navigator.pop(context);
  }

  _imageCrop(File imageFile) async {
    File croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Theme.of(context).primaryColor,
          toolbarTitle: 'Crop Image',
          toolbarWidgetColor: Theme.of(context).accentColor,
          activeControlsWidgetColor: Theme.of(context).accentColor,
        ));
    return croppedImage;
  }

  _displayProfileImage() {
    if (_profileImage == null) {
      if (widget.user.profileUrl.isEmpty) {
        return null;
      } else {
        return CachedNetworkImageProvider(widget.user.profileUrl);
      }
    } else {
      return FileImage(_profileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(birthdate);
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Feather.x),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.headline6,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Feather.check,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              onPressed: () {
                setState(() {
                  _submitting = true;
                });
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        contentPadding: EdgeInsets.all(16),
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircularProgressIndicator(strokeWidth: 1),
                              SizedBox(width: 20),
                              Text(
                                'Saving..',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                        ],
                      );
                    });
                _submit();
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    minRadius: 50,
                    maxRadius: 80,
                    backgroundImage: _displayProfileImage(),
                    backgroundColor:
                        Theme.of(context).accentColor.withOpacity(0.3),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Change Profile Photo',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      _showSelectPhotoDialog();
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyText1,
                    initialValue: username,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Feather.user,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      hintText: 'Username',
                    ),
                    validator: (input) => input.trim().length < 1
                        ? 'Please enter a valid username'
                        : input.contains(' ')
                            ? 'Please leave no spaces between letters'
                            : null,
                    onSaved: (input) => username = input,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyText1,
                    initialValue: name,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Feather.user,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      hintText: 'Name',
                    ),
                    validator: (input) => input.trim().length < 1
                        ? 'Please enter a valid name'
                        : null,
                    onSaved: (input) => name = input,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyText1,
                    initialValue: email,
                    maxLines: 1,
                    autofocus: false,
                    onTap: () => editEmailSheet(),
                    decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(
                          Feather.mail,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                        hintText: 'Email'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                      style: Theme.of(context).textTheme.bodyText1,
                      decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: Icon(
                            Feather.phone,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          hintText: 'Phone Number'),
                      autofocus: false,
                      onTap: () => editPhoneSheet()),
                  SizedBox(height: 20),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyText1,
                    initialValue: bio,
                    maxLength: 150,
                    maxLines: 15,
                    minLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Feather.file_text,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      hintText: 'Bio',
                    ),
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    validator: (input) =>
                        input.length > 150 ? 'Your bio is too long' : null,
                    onSaved: (input) => bio = input,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: DateTimeField(
                          style: Theme.of(context).textTheme.bodyText1,
                          onSaved: (input) => birthdate = input.toString(),
                          onShowPicker: (context, birthday) {
                            return showDatePicker(
                              context: context,
                              firstDate: DateTime(1950),
                              initialDate: birthdate ?? DateTime.now(),
                              lastDate: DateTime.now(),
                            );
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            prefixIcon: Icon(
                              Feather.calendar,
                              color: Theme.of(context).primaryIconTheme.color,
                            ),
                            hintText: 'Birthdate',
                            suffixIcon: Icon(
                              Feather.x,
                              color: Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                          format: DateFormat('yyyy-MM-dd'),
                        ),
                      ),
                      SizedBox(height: 20),
                      RadioButtonGroup(
                        labels: <String>[
                          'Male',
                          'Female',
                        ],
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        padding: EdgeInsets.all(5.0),
                        onSelected: (input) => gender = input,
                        orientation: GroupedButtonsOrientation.HORIZONTAL,
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                      onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return CustomDialog(
                                  title: 'Delete Account',
                                  content: Text(
                                      'Leaving so soon..Are you sure you want to delete your account?, you can:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                  mainActionText: 'Deactivate Account',
                                  secondaryActionText: 'Im sure, Delete',
                                  function1: () {
                                    deactivateString = 'Delete';
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AccountPage(
                                                deactivateString:
                                                    deactivateString)));
                                  },
                                  function: () {
                                    deactivateString = 'Deactivate';
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AccountPage(
                                                deactivateString:
                                                    deactivateString)));
                                  });
                            },
                          ),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          'Delete Account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .apply(color: Colors.white),
                        ),
                      ),
                      style: TextButton.styleFrom(backgroundColor: Colors.red)),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      deactivateString = 'Deactivate';
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AccountPage(
                                  deactivateString: deactivateString)));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('Deactivate Account',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  editEmailSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 20, left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text('Change Email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 30),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  initialValue: email,
                  maxLines: 1,
                  decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Feather.mail,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      hintText: 'Email'),
                  validator: (input) =>
                      !input.contains('@') ? 'Write a valid email' : null,
                  onSaved: (input) => email = input,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Change',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        });
  }

  editPhoneSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 20, left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('Change Phone',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 30),
                PhoneField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text('Verify')),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
  }
}
