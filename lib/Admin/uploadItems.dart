import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  bool get wantKeepAlive => true;
  File file;
  TextEditingController _descriptionTextEditingController =
      TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _shortInfoTextEditingController =
      TextEditingController();
  String productId = DateTime.now().microsecondsSinceEpoch.toString();
  bool uploading = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return file == null
        ? displayAdminHomeScreen()
        : displayAdminUploadFormScreen();
  }

  displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.green, Colors.orange],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.border_color, color: Colors.white),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (c) => AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
            child: Text(
              "Çıkış",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (c) => SplashScreen());
              Navigator.pushReplacement(context, route);
            },
          ),
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [Colors.green, Colors.orange],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shop,
              color: Colors.white,
              size: 100.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.0)),
                  child: Text(
                    "Ürün işlemleri",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      File files = new File("login.jpeg");
                      file = files;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (con) {
        return SimpleDialog(
          title: Text(
            "Ürün Fotoğrafı",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Kamerayı Aç",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: capturePhotoWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Galeriyi Aç",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: PickPhotoFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "İptal",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  capturePhotoWithCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600.0, maxWidth: 900);

    setState(() {
      file = imageFile;
    });
  }

  // ignore: non_constant_identifier_names
  PickPhotoFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = imageFile;
    });
  }

  displayAdminUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.green, Colors.orange],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null : () => uploadImageAndSaveItemInfo(),
            child: Text(
              "Ekle",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FlatButton(
            onPressed: () => readItems(),
            child: Text(
              "Oku",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          FlatButton(
            onPressed: () => deleteItem(),
            child: Text(
              "Sil",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          FlatButton(
            onPressed: () => updateItemInfo(),
            child: Text(
              "Güncelle",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),

          Padding(padding: EdgeInsets.only(top: 12.0)),
          RaisedButton(
            onPressed: () => takeImage(context),
            color: Colors.red,
            child: Text(
              "Fotoğraf Ekle",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.red,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _shortInfoTextEditingController,
                decoration: InputDecoration(
                  hintText: "Kısa Bilgi",
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //Araya Bölme koyduk
          Divider(color: Colors.red),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.red,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                  hintText: "Başlık",
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //Araya Bölme koyduk
          Divider(color: Colors.red),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.red,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Açıklama",
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //Araya Bölme koyduk
          Divider(color: Colors.red),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.red,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Fiyat",
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //Araya Bölme koyduk
          Divider(color: Colors.red),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

  clearFormInfo() {
    setState(() {
      file = null;
      _descriptionTextEditingController.clear();
      _priceTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _titleTextEditingController.clear();
    });
  }

  uploadImageAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl = await uploadItemImage(file);
    saveItemInfo(imageDownloadUrl);
  }

  Future<String> uploadItemImage(mFileImage) async {
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask =
        storageReference.child("product_$productId.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveItemInfo(String downloadUrl) {
    final itemsRef = Firestore.instance.collection("items");
    itemsRef.document(productId).setData({
      "title": _titleTextEditingController.text.trim(),
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": int.parse(_priceTextEditingController
          .text), //kayıt tarihini ve mevcut olup olmadığını buradan aldık
      "publishedDate": DateTime.now(),
      "status": "availible",
      //
      "thumbnailUrl": downloadUrl,
    });
    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().microsecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
    });
  }

  readItems() {
    Firestore.instance.collection("items").getDocuments().then((snapshot) {
      snapshot.documents.forEach((result) {
        if (result.data["title"] == _titleTextEditingController.text.trim()) {
          File fi = new File(result.data["thumbnailUrl"]);
          setState(() {
            file = fi;
            _descriptionTextEditingController.text =
                result.data["longDescription"].toString();
            _shortInfoTextEditingController.text =
                result.data["shortInfo"].toString();
            _priceTextEditingController.text = result.data["price"].toString();
          });
        }
      });
    });
  }

  updateItemInfo() {
    Firestore.instance.collection("items").getDocuments().then((snapshot) {
      snapshot.documents.forEach((result) {
        if (result.data["title"] == _titleTextEditingController.text.trim()) {
          final itemsRef = Firestore.instance.collection("items");
          itemsRef.document(result.documentID).updateData({
            "title": _titleTextEditingController.text.trim(),
            "shortInfo": _shortInfoTextEditingController.text.trim(),
            "longDescription": _descriptionTextEditingController.text.trim(),
            "price": int.parse(_priceTextEditingController
                .text), //kayıt tarihini ve mevcut olup olmadığını buradan aldık

            //
          });
          setState(() {
            file = null;
            uploading = false;
            productId = DateTime.now().microsecondsSinceEpoch.toString();
            _descriptionTextEditingController.clear();
            _titleTextEditingController.clear();
            _shortInfoTextEditingController.clear();
            _priceTextEditingController.clear();
          });
        }
      });
    });
  }

  deleteItem() {
    Firestore.instance.collection("items").getDocuments().then((snapshot) {
      snapshot.documents.forEach((result) {
        if (result.data["title"] == _titleTextEditingController.text.trim()) {
          DocumentReference documentReference = Firestore.instance
              .collection("items")
              .document(result.documentID);
          documentReference.delete().whenComplete(() => null);
        }
      });
    });
  }
}
