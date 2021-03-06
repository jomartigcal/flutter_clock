// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'hour_indicator.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class TigcalClock extends StatefulWidget {
  const TigcalClock(this.model);

  final ClockModel model;

  @override
  _TigcalClockState createState() => _TigcalClockState();
}

class _TigcalClockState extends State<TigcalClock> {
  var _now = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(TigcalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [TigcalClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color(0xFF002171),
            highlightColor: Color(0xFF633597),
            accentColor: Color(0xFFB71C1C),
            backgroundColor: Color(0xFFE2F1F8),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFF4D82FF),
            highlightColor: Color(0xFF8F75FF),
            accentColor: Color(0xFFFF3838),
            backgroundColor: Color(0xFF212121),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_now);
    final minute = DateFormat('mm').format(_now);
    final hourMinuteTime = DefaultTextStyle(
      style: TextStyle(
          color: customTheme.primaryColor,
          fontSize: 40.0,
          fontWeight: FontWeight.bold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hour + ':' + minute),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DrawnHand(
              color: customTheme.primaryColor,
              thickness: 8,
              size: 0.5,
              angleRadians: _now.minute * radiansPerTick,
            ),
            DrawnHand(
              color: customTheme.primaryColor,
              thickness: 10,
              size: 0.3,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
            ),
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 4,
              size: 0.7,
              angleRadians: _now.second * radiansPerTick,
            ),
            HourIndicator(
              color: customTheme.highlightColor,
              thickness: 8,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: customTheme.highlightColor,
              ),
            ),
            Positioned(
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: hourMinuteTime,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
