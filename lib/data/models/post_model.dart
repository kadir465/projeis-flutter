class Posts {
  final List<Post> posts;
  Posts({required this.posts});

  factory Posts.fromJson(Map<String, dynamic> json) {
    List<Post> postList = [];
    for (var i in json["gorevler"]) {
      postList.add(Post.fromJson(i));
    }
    return Posts(posts: postList);
  }
}

class Post {
  final String aciklama;
  final String baslik;
  final String atanan;
  final String mail;

  Post({
    required this.aciklama,
    required this.baslik,
    required this.atanan,
    required this.mail,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      aciklama: json["aciklama"],
      baslik: json["baslik"],
      atanan: json["atanan"],
      mail: json["mail"],
    );
  }
}
