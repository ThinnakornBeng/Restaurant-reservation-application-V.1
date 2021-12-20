import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_beng_queue_app/model/detail_notification_model.dart';
import 'package:flutter_application_beng_queue_app/model/queue_model.dart';
import 'package:flutter_application_beng_queue_app/model/user_model.dart';

class DetailQueueForRrst extends StatefulWidget {
  final QueueModel queueModel;
  final String uidQueue;
  const DetailQueueForRrst(
      {Key key, @required this.queueModel, @required this.uidQueue})
      : super(key: key);

  @override
  _DetailQueueForRrstState createState() => _DetailQueueForRrstState();
}

class _DetailQueueForRrstState extends State<DetailQueueForRrst> {
  QueueModel queueModel;
  var uidQueue;
  var queueStatus = true;
  var body;
  var title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queueModel = widget.queueModel;
    uidQueue = widget.uidQueue;

    print('UidQueue ==>> $uidQueue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: ElevatedButton(
              onPressed: () async {
                updateQueueStatus();
                String uidUser = queueModel.uidUser;
                // print('You click $uidUser');
                await Firebase.initializeApp().then((value) async {
                  await FirebaseFirestore.instance
                      .collection('userTable')
                      .doc(uidUser)
                      .get()
                      .then((value) async {
                    UserModel userModel = UserModel.fromMap(value.data());
                    String token = userModel.token;
                    // print('Token Is ====>>>> $token');

                    this.title = 'คุณ ${queueModel.nameUser} ';
                    this.body = 'ถึงคิวของคุณแล้วกรุณาไปใช้บริการภายใน 10 นาที';

                    var path =
                        'https://www.androidthai.in.th/mea/bengapiNotification.php?isAdd=true&token=$token&title=$title&body=$body';

                    await Dio().get(path).then((value) {
                      print('Value ===>>> $value');
                    });
                    addDetailNotification();
                  });
                });
              },
              child: Text('SenNoti'))),
    );
  }

  Future<Null> addDetailNotification() async {
    await Firebase.initializeApp().then((value) async {
      DetailNotificationModel detailNotificationModel =
          DetailNotificationModel(title: title, body: body);
      Map<String, dynamic> data = detailNotificationModel.toMap();
      await FirebaseFirestore.instance
          .collection('userTable')
          .doc(queueModel.uidUser)
          .collection('detailNotificationTable')
          .doc()
          .set(data)
          .then((value) {
        print('Add Notification to database success');
      });
    });
  }

  Future<void> updateQueueStatus() async {
    Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('restaurantTable')
          .doc(queueModel.uidRest)
          .collection('restaurantQueueTable')
          .doc(uidQueue)
          .update({"queueStatus": queueStatus}).then((value) {
        print('Uddate Queue Status Success');
      });
    });
  }
}
