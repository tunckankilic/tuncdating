import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tuncdating/models/person.dart';
import 'package:tuncdating/services/global.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;
  @override
  void onInit() {
    usersProfileList.bindStream(FirebaseFirestore.instance
        .collection("users")
        .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      List<Person> profilesList = [];
      for (var eachProfile in querySnapshot.docs) {
        profilesList.add(Person.fromDataSnapshot(eachProfile));
      }
      return profilesList;
    }));
    super.onInit();
  }

  favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserId)
        .get();

    //remove the favorite from database
    if (document.exists) {
      //remove currentUserId from the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserId)
          .delete();

      //remove profile person [toUserID] from the favoriteSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(toUserID)
          .delete();
    } else //mark as favorite //add favorite in database
    {
      //add currentUserId to the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserId)
          .set({});

      //add profile person [toUserID] to the favoriteSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(toUserID)
          .set({});

      //send notification
    }

    update();
  }

  void favoriteSendFavoriteReceived(
      {required String toUserId, required String senderName}) {}
}