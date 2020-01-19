import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drawing_animation/drawing_animation.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  List<String> _assets;
  List<bool> _run;
  StreamController<bool> _streamController = StreamController<bool>.broadcast();
  bool _clear = false;
  Duration _duration = Duration(milliseconds: 600);

  void setAssets() {
    final h =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final m = DateFormat('mm').format(_dateTime);
    _run = [false, false, false, false, false];
    _assets = [h[0], h[1], "s", m[0], m[1]];
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
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
    widget.model.dispose();
    _streamController.close();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _clear = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_assets == null) {
      setAssets();
    }
    return Container(
      color: Colors.white,
      child: Stack(children: <Widget>[
        Row(
          children: <Widget>[
            Spacer(flex: 2),
            Expanded(
              flex: 20,
              child: Digit(
                _assets[0],
                _run[0],
                _streamController.stream,
                () => setState(() {
                  _run[1] = true;
                }),
                _duration,
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 20,
              child: Digit(
                _assets[1],
                _run[1],
                _streamController.stream,
                () => setState(() {
                  _run[2] = true;
                }),
                _duration,
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 8,
              child: Digit(
                _assets[2],
                _run[2],
                _streamController.stream,
                () => setState(() {
                  _run[3] = true;
                }),
                _duration * 0.5,
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 20,
              child: Digit(
                _assets[3],
                _run[3],
                _streamController.stream,
                () => setState(() {
                  _run[4] = true;
                }),
                _duration,
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 20,
              child: Digit(
                _assets[4],
                _run[4],
                _streamController.stream,
                () => setState(() {}),
                _duration,
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
        Digit(
          "clear",
          _clear,
          _streamController.stream,
          () => setState(() {
            _clear = false;
            _streamController.add(true);
            setAssets();
            _run[0] = true;
          }),
          _duration * 3,
        )
      ]),
    );
  }
}

class Digit extends StatefulWidget {
  Digit(this.assetName, this.run, this.stream, this.onFinish, this.duration);
  final String assetName;
  final bool run;
  final Stream<bool> stream;
  final VoidCallback onFinish;
  final Duration duration;

  @override
  DigitState createState() => DigitState();
}

class DigitState extends State<Digit> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });
    widget.stream.listen((reset) {
      if (reset) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.run) {
      _controller.forward();
    }
    return AnimatedDrawing.svg(
      "assets/" + widget.assetName + ".svg",
      controller: _controller,
    );
  }
}
