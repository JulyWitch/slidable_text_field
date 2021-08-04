import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LeafSlidableTextField extends LeafRenderObjectWidget {
  final Function(double value) onChange;
  LeafSlidableTextField({Key? key, required this.onChange, required this.value})
      : super(key: key);
  double value;
  @override
  void updateRenderObject(
      BuildContext context, covariant RenderLeafSlidableTextField renderObject) {
    renderObject
      ..thumbcurrentvalue = value
      ..onChange = onChange;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeafSlidableTextField(onChange: onChange, value: value);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class RenderLeafSlidableTextField extends RenderBox {
  RenderLeafSlidableTextField({Key? key, required this.onChange, required double value}) {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        updateSlider(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        updateSlider(details.localPosition);
      };
  }
  Function(double value) onChange;
  final double _thumbsize = 6;
  final double _thin = 2;
  final double _parentBorderRadius = 6;
  final double _parentBorderWidth = 1;
  double _thumbcurrentvalue = 0.0;
  set thumbcurrentvalue(double v) {
    _thumbcurrentvalue = v;
    markNeedsLayout();
    markNeedsPaint();
  }

  void updateSlider(Offset pos) {
    double dx = pos.dx.clamp(_thumbsize, size.width - _thumbsize);
    _thumbcurrentvalue = (dx / size.width);
    onChange(pos.dx.clamp(0, size.width) / size.width);
    // _thumbcurrentvalue = ((pos.dx / size.width));
    markNeedsLayout();
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final wid = constraints.maxWidth;
    final hei = _thumbsize + 5;
    size = constraints.constrain(Size(wid, hei));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy + 10);
    final Path path = Path()
      ..moveTo(
          _parentBorderRadius -
              math.sqrt(2) * _parentBorderRadius / 2 -
              _parentBorderWidth,
          -_parentBorderRadius +
              math.sqrt(2) * _parentBorderRadius / 2 -
              _parentBorderWidth)
      ..lineTo(size.width - _parentBorderWidth, -_parentBorderRadius / 2)
      ..quadraticBezierTo(size.width - _parentBorderRadius / 2, 0,
          size.width - _parentBorderRadius - _parentBorderWidth, 0)
      ..lineTo(_parentBorderRadius, 0)
      ..quadraticBezierTo(
          _thin, 0, _parentBorderWidth, -_parentBorderRadius / 2)
      ..close();
    final Paint paint = Paint()..color = Colors.blue.withOpacity(.3);
    canvas.drawPath(path, paint);
    double _thumbDx = _thumbcurrentvalue * size.width;

    final Path thumbLinePath = Path()
      ..moveTo(
          _parentBorderRadius -
              math.sqrt(2) * _parentBorderRadius / 2 -
              _parentBorderWidth,
          -_parentBorderRadius +
              math.sqrt(2) * _parentBorderRadius / 2 -
              _parentBorderWidth)
      ..lineTo(_thumbDx, -_parentBorderRadius / 2)
      ..lineTo(_thumbDx, 0)
      ..lineTo(_parentBorderRadius, 0)
      ..quadraticBezierTo(
          _thin, 0, _parentBorderWidth, -_parentBorderRadius / 2)
      ..close();
    final Paint thumbLinePaint = Paint()..color = Colors.green.shade700;
    canvas.drawPath(thumbLinePath, thumbLinePaint);

    final Paint thumbPaint = Paint()..color = Colors.green.shade800;
    canvas.drawCircle(Offset(_thumbDx, -_thin), _thumbsize, thumbPaint);
    canvas.restore();
  }

  late HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) _drag.addPointer(event);
  }
}