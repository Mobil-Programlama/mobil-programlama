import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cFlatHomeNumber = TextEditingController();
  final cState = TextEditingController();
  final cPostCode = TextEditingController();
  final cCity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (formKey.currentState.validate()) {
              final model = AddressModel(
                name: cName.text.trim(),
                state: cState.text.trim(),
                postcode: cPostCode.text,
                phoneNumber: cPhoneNumber.text,
                flatNumber: cFlatHomeNumber.text,
                city: cCity.text.trim(),
              ).toJson();
              EcommerceApp.firestore
                  .collection(EcommerceApp.collectionUser)
                  .document(EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.subCollectionAddress)
                  .document(DateTime.now().millisecondsSinceEpoch.toString())
                  .setData(model)
                  .then((value) {
                final snack = SnackBar(content: Text("Adres eklendi"));
                scaffoldKey.currentState.showSnackBar(snack);
                FocusScope.of(context).requestFocus(FocusNode());
                formKey.currentState.reset();
              });
            } //Firestore a gönderdik
          },
          label: Text("Ekle"),
          backgroundColor: Colors.red,
          icon: Icon(Icons.check),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Adres Ekle",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "İsim:",
                      controller: cName,
                    ),
                    MyTextField(
                      hint: "Tel No:",
                      controller: cPhoneNumber,
                    ),
                    MyTextField(
                      hint: "Daire No:",
                      controller: cFlatHomeNumber,
                    ),
                    MyTextField(
                      hint: "Şehir",
                      controller: cCity,
                    ),
                    MyTextField(
                      hint: "Ülke:",
                      controller: cState,
                    ),
                    MyTextField(
                      hint: "Posta Kodu:",
                      controller: cPostCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  MyTextField({
    Key key,
    this.hint,
    this.controller,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        //doğrulayıcı
        validator: (val) => val.isEmpty ? "Boş alan bırakılamaz" : null,
      ),
    );
  }
}
