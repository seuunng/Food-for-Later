import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultFoodModel {
  final String id; // 고유 ID
  final String mainCategory; // 대분류 카테고리 이름
  final String subCategory; // 소분류 아이템 이름
  final bool isDisabled; // 비활성화 여부
  final bool isDefaultFridgeCategory; // 기본 냉장고 카테고리 여부
  final DateTime? expirationDate; // 소비기한
  final DateTime? shelfLife; // 유통기한

  DefaultFoodModel({
  required this.id,
  required this.mainCategory,
  required this.subCategory,
  this.isDisabled = false, // 기본값은 활성화 상태
  this.isDefaultFridgeCategory = false, // 기본값은 기본 냉장고 카테고리가 아님
  this.expirationDate, // 소비기한
  this.shelfLife, // 유통기한
  });

  // Firestore에서 데이터를 가져올 때 사용하는 팩토리 메서드
  factory DefaultFoodModel.fromJson(Map<String, dynamic> json, String id) {
  return DefaultFoodModel(
  id: id,
  mainCategory: json['mainCategory'] as String,
  subCategory: json['subCategory'] as String,
  isDisabled: json['isDisabled'] as bool? ?? false,
  isDefaultFridgeCategory: json['isDefaultFridgeCategory'] as bool? ?? false,
  expirationDate: json['expirationDate'] != null
  ? (json['expirationDate'] as Timestamp).toDate()
      : null, // Firestore에서 Timestamp로 저장된 경우 DateTime으로 변환
  shelfLife: json['shelfLife'] != null
  ? (json['shelfLife'] as Timestamp).toDate()
      : null, // Firestore에서 Timestamp로 저장된 경우 DateTime으로 변환
  );
  }

  // Firestore에 저장할 때 Map 형태로 변환하는 메서드
  Map<String, dynamic> toMap() {
  return {
  'mainCategory': mainCategory,
  'subCategory': subCategory,
  'isDisabled': isDisabled,
  'isDefaultFridgeCategory': isDefaultFridgeCategory,
  'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
  'shelfLife': shelfLife != null ? Timestamp.fromDate(shelfLife!) : null,
  };
  }
  }