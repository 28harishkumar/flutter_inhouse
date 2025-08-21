/// Represents a callback from the native tracking SDK
class TrackingCallback {
  /// The type of callback (e.g., "install_referrer", "deep_link", etc.)
  final String callbackType;
  
  /// JSON data associated with the callback
  final String data;
  
  const TrackingCallback({
    required this.callbackType,
    required this.data,
  });
  
  /// Creates a TrackingCallback from a Map
  factory TrackingCallback.fromMap(Map<String, dynamic> map) {
    return TrackingCallback(
      callbackType: map['callbackType'] as String,
      data: map['data'] as String,
    );
  }
  
  /// Converts the TrackingCallback to a Map
  Map<String, dynamic> toMap() {
    return {
      'callbackType': callbackType,
      'data': data,
    };
  }
  
  @override
  String toString() {
    return 'TrackingCallback(callbackType: $callbackType, data: $data)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackingCallback &&
        other.callbackType == callbackType &&
        other.data == data;
  }
  
  @override
  int get hashCode => callbackType.hashCode ^ data.hashCode;
} 