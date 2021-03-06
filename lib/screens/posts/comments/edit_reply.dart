import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/models/comment_model.dart';
import 'package:glitcher/models/post_model.dart';
import 'package:glitcher/models/user_model.dart';
import 'package:glitcher/screens/posts/new_post/widget/create_bottom_icon.dart';
import 'package:glitcher/screens/posts/new_post/widget/create_post_image.dart';
import 'package:glitcher/screens/posts/new_post/widget/widget_view.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:glitcher/widgets/caching_image.dart';
import 'package:glitcher/widgets/custom_loader.dart';
import 'package:glitcher/widgets/custom_url_text.dart';
import 'package:glitcher/widgets/custom_widgets.dart';
import 'package:glitcher/widgets/gradient_appbar.dart';

class EditReply extends StatefulWidget {
  final Post post;
  final Comment comment;
  final Comment reply;
  final User user;

  EditReply({Key key, this.post, this.comment, this.user, this.reply})
      : super(key: key);
  _AddReplyPageState createState() => _AddReplyPageState();
}

class _AddReplyPageState extends State<EditReply> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isScrollingDown = false;
  ScrollController scrollController;

  File _image;
  var _video;
  var _uploadedFileURL;
  String _mentionText = '';
  var words = [];
  GlobalKey<AutoCompleteTextFieldState<String>> autocompleteKey = GlobalKey();
  TextEditingController _textEditingController;

  //YoutubePlayer
  bool _showYoutubeUrl = false;
  String _youtubeId;

  bool canSubmit = true;

  @override
  void dispose() {
    scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController = ScrollController();
    _textEditingController = TextEditingController();
    scrollController..addListener(_scrollListener);
    //DatabaseService.getGameNames();

    super.initState();

    setState(() {
      _textEditingController.text = widget.reply.text;
    });
  }

  _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {}
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelected(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit Comment to save in firebase database
  void _submitButton() async {
    Navigator.of(context).push(CustomScreenLoader());
    if (_textEditingController.text.isNotEmpty) {
      DatabaseService.editReply(widget.post.id, widget.comment.id,
          widget.reply.id, _textEditingController.text);

//      await NotificationHandler.sendNotification(
//          widget.user.id,
//          Constants.loggedInUser.username + ' commented on your post',
//          _textEditingController.text,
//          widget.comment.id,
//          'comment');

      await AppUtil.checkIfContainsMention(
          _textEditingController.text, widget.post.id);

      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: new Text("A comment can't be empty!"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    /// Checks for username in tweet description
    /// If foud sends notification to all tagged user
    /// If no user found or not compost tweet screen is closed and redirect back to home page.
    /// Hide running loader on screen
    Navigator.of(context).pop();

    /// Navigate back to home page
    Navigator.of(context)
        .pushNamed(RouteList.post, arguments: {'post': widget.post});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          flexibleSpace: gradientAppBar(context),
          title: Text('Edit Reply'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                if (canSubmit) {
                  _submitButton();
                } else {
                  //print('can\'t submit = $canSubmit');
                }
              },
              icon: Icon(
                Icons.send,
                color: canSubmit
                    ? switchColor(
                        context, MyColors.lightPrimary, MyColors.darkPrimary)
                    : MyColors.darkGrey,
              ),
            )
          ],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              _onBackPressed();
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: scrollController,
                child: _ComposeTweet(this),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CreateBottomIcon(
                  isComment: true,
                  textEditingController: _textEditingController,
                  onImageIconSelected: _onImageIconSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to discard this comment?'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("NO"),
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("YES"),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void checkIfContainsMention(String comment) async {
    comment.split(' ').forEach((word) async {
      if (word.startsWith('@')) {
        User user =
            await DatabaseService.getUserWithUsername(word.substring(1));

        await NotificationHandler.sendNotification(
            user.id,
            'New post mention',
            Constants.currentUser.username + ' mentioned you in a comment',
            widget.comment.id,
            'mention');
      }
    });
  }
}

class _ComposeTweet extends WidgetView<EditReply, _AddReplyPageState> {
  _ComposeTweet(this.viewState) : super(viewState);

  final _AddReplyPageState viewState;

  Widget _tweerCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30),
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width: Sizes.fullWidth(context) - 100,
                      child: UrlText(
                        text: widget.comment.text ?? '',
                        style: TextStyle(
                          color: switchColor(
                              context, MyColors.darkGrey, MyColors.lightCardBG),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        urlStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  UrlText(
                    text: 'Replying to ${widget.user.username}',
                    style: TextStyle(
                      color: MyColors.darkPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CacheThisImage(
                  imageUrl: widget.user.profileImageUrl,
                  imageShape: BoxShape.circle,
                  width: Sizes.sm_profile_image_w,
                  height: Sizes.sm_profile_image_h,
                  defaultAssetImage: Strings.default_profile_image,
                ),
                SizedBox(width: 10),
//                ConstrainedBox(
//                  constraints: BoxConstraints(
//                      minWidth: 0, maxWidth: Sizes.fullWidth(context) * .5),
//                  child: TitleText(widget.username,
//                      fontSize: 16,
//                      fontWeight: FontWeight.w800,
//                      overflow: TextOverflow.ellipsis),
//                ),
//                SizedBox(width: 3),
//                viewState.model.user.isVerified
//                    ? customIcon(
//                        context,
//                        icon: AppIcon.blueTick,
//                        istwitterIcon: true,
//                        iconColor: AppColor.primary,
//                        size: 13,
//                        paddingIcon: 3,
//                      )
//                    :
                SizedBox(width: 0),
//                SizedBox(width: viewState.model.user.isVerified ? 5 : 0),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(RouteList.profile, arguments: {
                      'userId': widget.user.id,
                    });
                  },
                  child: customText('@${widget.user.username}',
                      style: TextStyle(
                          color: switchColor(context, MyColors.lightPrimary,
                              MyColors.darkPrimary))),
                ),
                SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: customText(
                      '- ${Functions.formatTimestamp(widget.comment.timestamp)}',
                      style: TextStyle(
                          color: switchColor(
                              context, MyColors.darkGrey, Colors.white70),
                          fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.fullHeight(context),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _tweerCard(context),
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CacheThisImage(
                    imageUrl: loggedInProfileImageURL,
                    imageShape: BoxShape.circle,
                    width: Sizes.sm_profile_image_w,
                    height: Sizes.sm_profile_image_h,
                    defaultAssetImage: Strings.default_profile_image,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: MyColors.darkPrimary,
                      onChanged: (text) {
                        if (text.length > Sizes.maxPostChars) {
                          viewState.setState(() {
                            viewState.canSubmit = false;
                          });
                        } else {
                          viewState.setState(() {
                            viewState.canSubmit = true;
                          });
                        }
                        // Mention Users
                        viewState.setState(() {
                          viewState.words = text.split(' ');
                          viewState._mentionText = viewState.words.length > 0 &&
                                  viewState.words[viewState.words.length - 1]
                                      .startsWith('@')
                              ? viewState.words[viewState.words.length - 1]
                              : '';
                        });
                      },
                      maxLength: Sizes.maxPostChars,
                      minLines: 5,
                      maxLines: 15,
                      autofocus: true,
                      maxLengthEnforced: true,
                      controller: viewState._textEditingController,
                      decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintText: 'Post your reply...'),
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
              viewState._mentionText.length > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 45.0),
                      child: ListView.builder(
                        itemCount: Constants.userFriends.length,
                        itemBuilder: (context, index) {
                          String friendUsername =
                              Constants.userFriends[index].username;
                          //print('username:' + friendUsername);
                          if (('@' + friendUsername.toLowerCase())
                              .contains(viewState._mentionText.toLowerCase()))
                            return ListTile(
                              leading: CacheThisImage(
                                imageUrl: Constants
                                    .userFriends[index].profileImageUrl,
                                imageShape: BoxShape.circle,
                                width: 40.0,
                                height: 40.0,
                                defaultAssetImage:
                                    Strings.default_profile_image,
                              ),
                              title:
                                  Text(Constants.userFriends[index].username),
                              onTap: () {
                                if (viewState._textEditingController.text
                                    .contains('@$friendUsername')) {
                                  AppUtil.showSnackBar(
                                      context, 'User already mentioned!');
                                  return;
                                }
                                viewState.setState(() {
                                  viewState._mentionText = '';
                                  String s = viewState
                                      ._textEditingController.text
                                      .replaceFirst(
                                          RegExp(r'\B\@\w+'),
                                          '@$friendUsername',
                                          viewState._textEditingController.text
                                                      .length <
                                                  8
                                              ? 0
                                              : viewState._textEditingController
                                                      .selection.baseOffset -
                                                  8);
                                  viewState._textEditingController.text = s;

                                  viewState._textEditingController.selection =
                                      TextSelection.collapsed(
                                          offset: viewState
                                              ._textEditingController
                                              .text
                                              .length);
                                });
                              },
                            );

                          return SizedBox();
                        },
                        shrinkWrap: true,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                CreatePostImage(
                  image: viewState._image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
