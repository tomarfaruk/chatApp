class User {
  String displayName;
  String profilePicture;
  String id;
  String email;
  String phone;
  bool isActive;
  int rewardAd;
  String social;

  User(
      {this.displayName,
      this.profilePicture,
      this.id,
      this.email,
      this.phone,
      this.rewardAd,
      this.social,
      this.isActive});

  User.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    profilePicture = json['profilePicture'];
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    isActive = json['isActive'];
    rewardAd = json['rewardAd'];
    social = json['social'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['profilePicture'] = this.profilePicture;
    data['id'] = this.id;
    data['email'] = this.email;
    data['isActive'] = this.isActive;
    data['phone'] = this.phone;
    data['rewardAd'] = this.rewardAd;
    data['social'] = this.social;
    return data;
  }
}
