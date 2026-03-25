import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeis/data/models/post_model.dart';

class FirebaseService {
  final CollectionReference userCol = FirebaseFirestore.instance.collection(
    "gorevler",
  );

  Future<Posts> getUserPosts() async {
    QuerySnapshot querySnapshot = await userCol.get();
    
    List<Map<String, dynamic>> docsData =
        querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
    
    final postsModel = Posts.fromJson({"gorevler": docsData});
    
    return postsModel;
  }

  Stream<Posts> getUserPostsAsStream() {
    return userCol.snapshots().map((querySnapshot) {
      List<Map<String, dynamic>> docsData =
          querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
      
      return Posts.fromJson({"gorevler": docsData});
    });
  }
}
