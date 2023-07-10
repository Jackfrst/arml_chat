import 'package:arml_chatbot/utils/constants/app_colors.dart';
import 'package:arml_chatbot/utils/constants/string_constant.dart';
import 'package:arml_chatbot/utils/models/chat_massage.dart';
import 'package:arml_chatbot/utils/response_generator.dart';
import 'package:arml_chatbot/utils/resuable_functions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool isLoading = false;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    String value = botMessage;
    _addBotMessage(value);
  }

  void _addBotMessage(String message) {
    setState(() {
      var processedMessage = postProcessText(message);
      _messages.add(
        ChatMessage(
          text: processedMessage,
          chatMessageType: ChatMessageType.bot,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1)).then((_) {
        _scrollDown(); // Scroll to the latest message
      });
    });
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorAppBar,
        title: Text(
          'ARML TECH',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.colorAppBarText,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(bottom: isKeyboardVisible ? 300 : 0),
                  child: _buildChatScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: [
        Expanded(
          child: _buildList(),
        ),
        Visibility(
          visible: isLoading,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: SpinKitThreeBounce(
              color: AppColors.colorAppBarText,
              size: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              _buildInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    var messages = _messages.reversed.toList();
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        var message = messages[index];
        return ChatMessageWidget(
          message: message,
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        cursorColor: AppColors.colorAppBarText,
        style: const TextStyle(color: AppColors.colorWhite),
        controller: _textController,
        decoration: InputDecoration(
          fillColor: AppColors.colorTextField,
          filled: true,
          hintText: "Hungry? Let’s get started",
          suffixIcon: Visibility(
            //visible: !isLoading,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                  padding: const EdgeInsets.only(right: 4),
                  icon: SvgPicture.asset("assets/images/messageSend.svg"),
                  onPressed: !isLoading
                      ? () async {
                          setState(() {
                            _messages.add(
                              ChatMessage(
                                text: _textController.text,
                                chatMessageType: ChatMessageType.user,
                              ),
                            );
                            isLoading = true;
                          });

                          var input = _textController.text.toLowerCase();

                          _textController.clear();

                          // Apply DALI data augmentation
                          // var augmentedData = await generateImageResponse(input);
                          if (input.startsWith('image') ||
                              input.startsWith('generate') ||
                              input.startsWith('create') ||
                              input.startsWith('photo') ||
                              input.startsWith('print') ||
                              input.endsWith('image') ||
                              input.endsWith('generate') ||
                              input.endsWith('create') ||
                              input.endsWith('photo') ||
                              input.endsWith('print')) {
                            generateImageResponse(input).then((value) {
                              //print('Generated response: $value');
                              setState(() {
                                isLoading = false;
                                _messages.add(
                                  ChatMessage(
                                    text: value,
                                    chatMessageType: ChatMessageType.bot,
                                  ),
                                );
                                Future.delayed(const Duration(milliseconds: 50))
                                    .then((_) {
                                  _scrollDown(); // Scroll to the latest message
                                });
                              });
                            });
                          } else if (input.contains('contact') ||
                              input.contains('agent') ||
                              input.contains('customer support') ||
                              input.contains('owner') ||
                              input.contains('help') ||
                              input.contains('info') ||
                              input.contains('information') ||
                              input.contains('support')) {
                            _messages.add(
                              ChatMessage(
                                text:
                                    "This is our company's contact number: +1 646 583 3170. This number has been specifically designated to ensure efficient and prompt communication with our valued customers like you. Feel free to reach us.",
                                chatMessageType: ChatMessageType.bot,
                              ),
                            );
                            isLoading = false;
                          } else {
                            generateTextResponse(input).then((value) {
                              //print('Generated response: $value');
                              setState(() {
                                isLoading = false;
                                _messages.add(
                                  ChatMessage(
                                    text: value,
                                    chatMessageType: ChatMessageType.bot,
                                  ),
                                );
                                Future.delayed(const Duration(milliseconds: 50))
                                    .then((_) {
                                  _scrollDown(); // Scroll to the latest message
                                });
                              });
                            });
                          }

                          Future.delayed(const Duration(milliseconds: 50))
                              .then((_) {
                            _scrollDown(); // Scroll to the latest message
                          });
                        }
                      : () {}
                  // onPressed: () async {
                  //   setState(() {
                  //     _messages.add(
                  //       ChatMessage(
                  //         text: _textController.text,
                  //         chatMessageType: ChatMessageType.user,
                  //       ),
                  //     );
                  //     isLoading = true;
                  //   });
                  //
                  //   var input = _textController.text;
                  //
                  //   _textController.clear();
                  //
                  //   // Apply DALI data augmentation
                  //   // var augmentedData = await generateImageResponse(input);
                  //   if(input.startsWith('image')){
                  //     generateImageResponse(input).then((value) {
                  //       print('Generated response: $value');
                  //       setState(() {
                  //         isLoading = false;
                  //         _messages.add(
                  //           ChatMessage(
                  //             text: value,
                  //             chatMessageType: ChatMessageType.bot,
                  //           ),
                  //         );
                  //         Future.delayed(const Duration(milliseconds: 50))
                  //             .then((_) {
                  //           _scrollDown(); // Scroll to the latest message
                  //         });
                  //       });
                  //     });
                  //   }else{
                  //     generateTextResponse(input).then((value) {
                  //       print('Generated response: $value');
                  //       setState(() {
                  //         isLoading = false;
                  //         _messages.add(
                  //           ChatMessage(
                  //             text: value,
                  //             chatMessageType: ChatMessageType.bot,
                  //           ),
                  //         );
                  //         Future.delayed(const Duration(milliseconds: 50))
                  //             .then((_) {
                  //           _scrollDown(); // Scroll to the latest message
                  //         });
                  //       });
                  //     });
                  //   }
                  //
                  //   Future.delayed(const Duration(milliseconds: 50)).then((_) {
                  //     _scrollDown(); // Scroll to the latest message
                  //   });
                  // },
                  ),
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          hintStyle: const TextStyle(
              color: AppColors.colorHintText, fontWeight: FontWeight.w400),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  width: 1, color: AppColors.colorTextFieldBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  width: 1, color: AppColors.colorTextFieldBorder)),
        ),
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.text,
    required this.chatMessageType,
  }) : super(key: key);

  final ChatMessage message;
  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 2 / 3;
    final isUserMessage = message.chatMessageType == ChatMessageType.user;
    final borderRadius = (message.chatMessageType == ChatMessageType.bot &&
            message.text.startsWith('https://'))
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          )
        : BorderRadius.only(
            bottomLeft: Radius.circular(isUserMessage ? 8 : 0),
            bottomRight: Radius.circular(isUserMessage ? 0 : 8),
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
          );

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: (message.chatMessageType == ChatMessageType.bot &&
                message.text.startsWith('https://'))
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(2),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: isUserMessage
              ? AppColors.colorBlueTextBox
              : AppColors.colorGreyTextBox,
          borderRadius: borderRadius,
        ),
        // child:  Text(text),
        child: (message.chatMessageType == ChatMessageType.bot &&
                message.text.startsWith('https://'))
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: SizedBox(
                  height: 256,
                  width: 256,
                  child: Image.network(
                    //Uri.decodeFull(message.text),
                    message.text,
                    fit: BoxFit.fill,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.colorAppBarText)));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(message.text),
              ),
      ),
    );
  }
}
