import 'package:board_test/composited_scale_transform_follower/follower_scale_layer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CompositedScaleTransformFollower extends SingleChildRenderObjectWidget {
  const CompositedScaleTransformFollower({
    super.key,
    required this.link,
    this.showWhenUnlinked = true,
    this.offset = Offset.zero,
    this.followScaleTransform = false,
    this.targetAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    super.child,
  });
  final LayerLink link;
  final bool showWhenUnlinked;
  final bool followScaleTransform;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  @override
  RenderFollowerScaleLayer createRenderObject(BuildContext context) {
    return RenderFollowerScaleLayer(
      link: link,
      showWhenUnlinked: showWhenUnlinked,
      offset: offset,
      leaderAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      followScaleTransform: followScaleTransform,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFollowerScaleLayer renderObject) {
    renderObject
      ..link = link
      ..showWhenUnlinked = showWhenUnlinked
      ..offset = offset
      ..leaderAnchor = targetAnchor
      ..followScaleTransform = followScaleTransform
      ..followerAnchor = followerAnchor;
  }
}

class RenderFollowerScaleLayer extends RenderProxyBox {
  RenderFollowerScaleLayer({
    required LayerLink link,
    bool showWhenUnlinked = true,
    Offset offset = Offset.zero,
    bool followScaleTransform = false,
    Alignment leaderAnchor = Alignment.topLeft,
    Alignment followerAnchor = Alignment.topLeft,
    RenderBox? child,
  })  : _link = link,
        _showWhenUnlinked = showWhenUnlinked,
        _offset = offset,
        _leaderAnchor = leaderAnchor,
        _followerAnchor = followerAnchor,
        _followScaleTransform = followScaleTransform,
        super(child);

  LayerLink get link => _link;
  LayerLink _link;
  set link(LayerLink value) {
    if (_link == value) {
      return;
    }
    _link = value;
    markNeedsPaint();
  }

  bool get followScaleTransform => _followScaleTransform;
  bool _followScaleTransform;
  set followScaleTransform(bool value) {
    if (_followScaleTransform == value) {
      return;
    }
    _followScaleTransform = value;
    markNeedsPaint();
  }

  bool get showWhenUnlinked => _showWhenUnlinked;
  bool _showWhenUnlinked;
  set showWhenUnlinked(bool value) {
    if (_showWhenUnlinked == value) {
      return;
    }
    _showWhenUnlinked = value;
    markNeedsPaint();
  }

  Offset get offset => _offset;
  Offset _offset;
  set offset(Offset value) {
    if (_offset == value) {
      return;
    }
    _offset = value;
    markNeedsPaint();
  }

  Alignment get leaderAnchor => _leaderAnchor;
  Alignment _leaderAnchor;
  set leaderAnchor(Alignment value) {
    if (_leaderAnchor == value) {
      return;
    }
    _leaderAnchor = value;
    markNeedsPaint();
  }

  Alignment get followerAnchor => _followerAnchor;
  Alignment _followerAnchor;
  set followerAnchor(Alignment value) {
    if (_followerAnchor == value) {
      return;
    }
    _followerAnchor = value;
    markNeedsPaint();
  }

  @override
  void detach() {
    layer = null;
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  FollowerScaleLayer? get layer => super.layer as FollowerScaleLayer?;

  Matrix4 getCurrentTransform() {
    return layer?.getLastTransform() ?? Matrix4.identity();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (link.leader == null && !showWhenUnlinked) {
      return false;
    }
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: getCurrentTransform(),
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Size? leaderSize = link.leaderSize;
    assert(
      link.leaderSize != null || (link.leader == null || leaderAnchor == Alignment.topLeft),
      '$link: layer is linked to ${link.leader} but a valid leaderSize is not set. '
      'leaderSize is required when leaderAnchor is not Alignment.topLeft '
      '(current value is $leaderAnchor).',
    );
    if (layer == null) {
      layer = FollowerScaleLayer(
        followScaleTransform: followScaleTransform,
        link: link,
        showWhenUnlinked: showWhenUnlinked,
        unlinkedOffset: offset,
        followerAnchor: followerAnchor,
        followerSize: size,
        leaderAnchor: leaderAnchor,
        leaderSize: leaderSize,
        inputOffset: this.offset,
      );
    } else {
      layer
        ?..link = link
        ..followScaleTransform = followScaleTransform
        ..showWhenUnlinked = showWhenUnlinked
        ..followerAnchor = followerAnchor
        ..followerSize = size
        ..leaderAnchor = leaderAnchor
        ..leaderSize = leaderSize
        ..inputOffset = this.offset
        ..unlinkedOffset = offset;
    }
    context.pushLayer(
      layer!,
      super.paint,
      Offset.zero,
      childPaintBounds: const Rect.fromLTRB(
        double.negativeInfinity,
        double.negativeInfinity,
        double.infinity,
        double.infinity,
      ),
    );
    assert(() {
      layer!.debugCreator = debugCreator;
      return true;
    }());
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getCurrentTransform());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LayerLink>('link', link));
    properties.add(DiagnosticsProperty<bool>('showWhenUnlinked', showWhenUnlinked));
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(TransformProperty('current transform matrix', getCurrentTransform()));
  }
}
