import 'package:get/get_utils/src/extensions/internacionalization.dart';

class SpinSegmentModel {
  final int    id;
  String label;
  String type;
  int    value;
  int    probability;
  String color;

  SpinSegmentModel({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    required this.probability,
    required this.color,
  });

  factory SpinSegmentModel.fromJson(Map json) => SpinSegmentModel(
    id:          json['id']          ?? 0,
    label:       json['label']       ?? '',
    type:        json['type']        ?? 'none',
    value:       json['value']       ?? 0,
    probability: json['probability'] ?? 0,
    color:       json['color']       ?? '#FF6300',
  );

  Map<String, dynamic> toMap() => {
    'id':          id,
    'label':       label,
    'type':        type,
    'value':       value,
    'probability': probability,
    'color':       color,
  };

  SpinSegmentModel copyWith({
    String? label, String? type, int? value,
    int? probability, String? color,
  }) => SpinSegmentModel(
    id: id,
    label:       label       ?? this.label,
    type:        type        ?? this.type,
    value:       value       ?? this.value,
    probability: probability ?? this.probability,
    color:       color       ?? this.color,
  );

  String get typeLabel {
    switch (type) {
      case 'percent':       return 'seg_type_percent'.tr;
      case 'fixed':         return 'seg_type_fixed'.tr;
      case 'free_shipping': return 'seg_type_free_shipping'.tr;
      case 'none':          return 'seg_type_none'.tr;
      default:              return type;
    }
  }

  static List<SpinSegmentModel> mockList() => [
    SpinSegmentModel(id:1, label:'10% خصم',       type:'percent',       value:10, probability:35, color:'#FF6300'),
    SpinSegmentModel(id:2, label:'شحن مجاني',     type:'free_shipping', value:0,  probability:20, color:'#27AE60'),
    SpinSegmentModel(id:3, label:'SP 5,000',       type:'fixed',         value:5000,probability:15,color:'#185FA5'),
    SpinSegmentModel(id:4, label:'20% خصم',        type:'percent',       value:20, probability:10, color:'#8E44AD'),
    SpinSegmentModel(id:5, label:'حاول مجدداً',   type:'none',          value:0,  probability:20, color:'#B0BEC5'),
  ];
}


class SpinWheelConfig {
  bool   enabled;
  String spinLimit;

  SpinWheelConfig({
    required this.enabled,
    required this.spinLimit,
  });

  factory SpinWheelConfig.fromJson(Map json) => SpinWheelConfig(
    enabled:   json['enabled']    ?? false,
    spinLimit: json['spin_limit'] ?? 'daily',
  );

  static SpinWheelConfig mock() => SpinWheelConfig(
    enabled: true, spinLimit: 'daily',
  );
}
