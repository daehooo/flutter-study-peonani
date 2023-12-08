class Restaurant {
  late final restrntNm;
  late final restrntZip;
  late final restrntAddr;
  late final restrntDtlAddr;
  late final restrntInqrTel;
  late final rprsFod;
  late final salsTime;
  late final hldyGuid;
  late final restrntSumm;
  late final mapLat;
  late final mapLot;

  Restaurant({
    required this.restrntNm,
    required this.restrntZip,
    required this.restrntAddr,
    required this.restrntDtlAddr,
    required this.restrntInqrTel,
    required this.rprsFod,
    required this.salsTime,
    required this.hldyGuid,
    required this.restrntSumm,
    required this.mapLat,
    required this.mapLot,
  });

  Restaurant.fromMap(Map<String, dynamic>? map) {
    restrntNm = map?["restrntNm"] ?? "";
    restrntZip = map?["restrntZip"] ?? "";
    restrntAddr = map?["restrntAddr"] ?? "";
    restrntDtlAddr = map?["restrntDtlAddr"] ?? "";
    restrntInqrTel = map?["restrntInqrTel"] ?? "";
    rprsFod = map?["rprsFod"] ?? "";
    salsTime = map?["salsTime"] ?? "";
    hldyGuid = map?["hldyGuid"] ?? "";
    restrntSumm = map?["restrntSumm"] ?? "";
    mapLat = map?["mapLat"] ?? "";
    mapLot = map?["mapLot"] ?? "";
  }
}
