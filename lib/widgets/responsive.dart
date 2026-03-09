import 'dart:math' as math;
import 'package:flutter/material.dart';

class Responsive {
  static late double _sw;
  static late double _sh;
  static late double _textScale;

  static const double designW = 360;
  static const double designH = 800;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    // use usable height (exclude status/nav bars) so h() is flexible across devices
    final usableHeight = mq.size.height - mq.padding.top - mq.padding.bottom;
    _sw = mq.size.width / designW;
    _sh = usableHeight / designH;

    // prefer new API `textScaler.scale`; fallback to legacy value for older SDKs
    try {
      _textScale = (mq as dynamic).textScaler.scale as double;
    } catch (_) {
      // fallback: older SDKs only — keep for compatibility
      _textScale = mq.textScaleFactor;
    }
  }

  static double w(num v) => v * _sw;
  static double h(num v) => v * _sh;
  static double sp(num v) => v * (_sw < _sh ? _sw : _sh) / _textScale;
}
