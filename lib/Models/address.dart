class AddressModel {
  String name;
  String phoneNumber;
  String flatNumber;
  String city;
  String state;
  String postcode;

  AddressModel(
      {this.name,
      this.phoneNumber,
      this.flatNumber,
      this.city,
      this.state,
      this.postcode});

  AddressModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    flatNumber = json['flatNumber'];
    city = json['city'];
    state = json['state'];
    postcode = json['postcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phoneNumber'] = this.phoneNumber;
    data['flatNumber'] = this.flatNumber;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postcode'] = this.postcode;
    return data;
  }
}
