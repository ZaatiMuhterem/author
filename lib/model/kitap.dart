class Kitap {
  int? id;
  String isim;
  DateTime olusturulmaTarihi;
  int kategori;

  Kitap(this.isim, this.olusturulmaTarihi, this.kategori);

  Kitap.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        isim = map["isim"],
        olusturulmaTarihi =
            DateTime.fromMillisecondsSinceEpoch(map["olusturulmaTarihi"]),
        kategori = map["kategori"] ?? 0;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "isim": isim,
      "olusturulmaTarihi": olusturulmaTarihi.millisecondsSinceEpoch,
      "kategori": kategori,
    };
  }
}
