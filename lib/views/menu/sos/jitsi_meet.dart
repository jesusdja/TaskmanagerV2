import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';

class JitsiMeetVideo extends StatefulWidget {

  JitsiMeetVideo({required this.callRoom, required this.nameRoom, this.videoMuted = false});
  final bool callRoom;
  final String nameRoom;
  final bool videoMuted;

  @override
  _JitsiMeetVideoState createState() => _JitsiMeetVideoState();
}

class _JitsiMeetVideoState extends State<JitsiMeetVideo>{

  String nameRooms = '';
  String nameTablet = '';
  bool refresh = true;

  StreamSubscription? streamSubscriptionBloc;

  @override
  void initState() {
    super.initState();
    initialData();
    _initializeBloc();
  }

  Future initialData() async{
    await SharedPreferencesClass().setStringValue('S4CFamilyJitsyActivo','1');
    nameRooms = await SharedPreferencesClass().getValue('S4CRoom');
    nameTablet = await SharedPreferencesClass().getValue('S4CIdTablet');
    setState(() {});
    if(widget.callRoom){
      meet();
    }
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionBloc?.cancel();
    SharedPreferencesClass().setStringValue('S4CFamilyJitsyActivo','0');
  }

  Future meet() async {
    refresh = false;
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    _joinMeeting();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: S4CColors().colorLoginPageBack,
        body: Column(
          children: [
            appBarWidget(),
            Expanded(
              child: pageRefresh(),
            )
          ],
        ),
      ),
    );
  }

  Widget pageRefresh(){
    return Container(
      width: sizeW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: sizeW * 0.4,
            child: Text('Iniciando video conferencia con habitación $nameRooms',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),textAlign: TextAlign.center,),
          ),
          SizedBox(height: sizeH * 0.05,),
          circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.06,colorCircular: S4CColors().colorLoginPageText)
        ],
      ),
    );
  }

  Widget appBarWidget(){
    return Container(
      color: Colors.white,
      width: sizeW,
      padding: EdgeInsets.only(top: sizeH * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: sizeH * 0.01),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: sizeW * 0.02),
                  height: sizeH * 0.06,
                  width: sizeH * 0.25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.asset("assets/image/logo_lock.png").image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            splashColor: S4CColors().primary,
            focusColor: S4CColors().primary,
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(
              height: sizeH * 0.05,
              width: sizeH * 0.05,
              margin: EdgeInsets.only(right: sizeW * 0.03),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/icons_door_out${idTemplate == 0 ? '' : '_black'}.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionBloc = blocData.outList.listen((newVal) async {
        if(newVal.containsKey('closetJitsy') && newVal['closetJitsy']){
          String jitsyActivo = await SharedPreferencesClass().getValue('S4CFamilyJitsyActivo') ?? '0';
          if(jitsyActivo == '1'){
            JitsiMeet.closeMeeting();
            await SharedPreferencesClass().setStringValue('S4CFamilyJitsyActivo','0');
            Navigator.of(context).pop();
          }
        }
      });
    } catch (e) {}
  }

  Future _joinMeeting() async {
    try{
      String? serverUrl = 'https://meet.jit.si/';
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: false,
        FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
        FeatureFlagEnum.CALL_INTEGRATION_ENABLED: false,
        FeatureFlagEnum.RECORDING_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false,
      };
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      var options = JitsiMeetingOptions(room: widget.nameRoom)
        ..serverURL = serverUrl
        ..subject = "$nameTablet - $nameRooms"
        ..userDisplayName = nameRooms
        ..audioOnly = false
        ..videoMuted = widget.videoMuted
        ..audioMuted = false
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
            onError: (message) {
              print('JITSI : Error con el mensaje: $message');
              debugPrint("${options.room} Error con el mensaje: $message");
            },
            onConferenceJoined: (message) {
              print('JITSI : unido con mensaje: $message');
              debugPrint("${options.room} unido con mensaje: $message");
            },
            onConferenceWillJoin: (message) {
              print('JITSI : se unirá con el mensaje: $message');
              debugPrint("${options.room} se unirá con el mensaje: $message");
              refresh = true;
              setState(() {});
            },
            onConferenceTerminated: (message) async {
              print('JITSI : terminado con mensaje: $message');
              debugPrint("${options.room} terminado con mensaje: $message");
              blocData.inList.add({'closetJitsy' : true});
            },
            genericListeners: [
              JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    print('JITSI : readyToClose callback');
                    debugPrint("readyToClose callback");
                  }),
            ]),
      );
    }catch(e){
      print('${e.toString()}');
    }
  }
}
