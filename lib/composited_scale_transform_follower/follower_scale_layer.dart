import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ui' as ui;

class FollowerScaleLayer extends ContainerLayer {
  FollowerScaleLayer({
    required this.link,
    this.showWhenUnlinked = true,
    this.unlinkedOffset = Offset.zero,
    required this.inputOffset,
    required this.leaderAnchor,
    required this.followerAnchor,
    required this.leaderSize,
    required this.followerSize,
    required this.followScaleTransform,
  });

  bool followScaleTransform;
  LayerLink link;

  bool? showWhenUnlinked;

  Offset? unlinkedOffset;

  Offset inputOffset;
  Alignment leaderAnchor;
  Alignment followerAnchor;
  Size? leaderSize;
  Size followerSize;

  Offset? _lastLinkedOffset;

  Offset? _lastOffset;
  Matrix4? _lastTransform;
  Matrix4? _invertedTransform;
  bool _inverseDirty = true;

  Offset? _transformOffset(Offset localPosition) {
    if (_inverseDirty) {
      _invertedTransform = Matrix4.tryInvert(getLastTransform()!);
      _inverseDirty = false;
    }
    if (_invertedTransform == null) {
      return null;
    }
    final Vector4 vector = Vector4(localPosition.dx, localPosition.dy, 0.0, 1.0);
    final Vector4 result = _invertedTransform!.transform(vector);
    return Offset(result[0] - _lastLinkedOffset!.dx, result[1] - _lastLinkedOffset!.dy);
  }

  @override
  bool findAnnotations<S extends Object>(AnnotationResult<S> result, Offset localPosition, {required bool onlyFirst}) {
    if (link.leader == null) {
      if (showWhenUnlinked!) {
        return super.findAnnotations(result, localPosition - unlinkedOffset!, onlyFirst: onlyFirst);
      }
      return false;
    }
    final Offset? transformedOffset = _transformOffset(localPosition);
    if (transformedOffset == null) {
      return false;
    }
    return super.findAnnotations<S>(result, transformedOffset, onlyFirst: onlyFirst);
  }

  Matrix4? getLastTransform() {
    if (_lastTransform == null) {
      return null;
    }
    final Matrix4 result = Matrix4.translationValues(-_lastOffset!.dx, -_lastOffset!.dy, 0.0);
    result.multiply(_lastTransform!);
    return result;
  }

  static Matrix4 _collectTransformForLayerChain(List<ContainerLayer?> layers) {
    final Matrix4 result = Matrix4.identity();
    for (int index = layers.length - 1; index > 0; index -= 1) {
      layers[index]?.applyTransform(layers[index - 1], result);
    }
    return result;
  }

  static Layer? _pathsToCommonAncestor(
    Layer? a,
    Layer? b,
    List<ContainerLayer?> ancestorsA,
    List<ContainerLayer?> ancestorsB,
  ) {
    // No common ancestor found.
    if (a == null || b == null) {
      return null;
    }

    if (identical(a, b)) {
      return a;
    }

    if (a.depth < b.depth) {
      ancestorsB.add(b.parent);
      return _pathsToCommonAncestor(a, b.parent, ancestorsA, ancestorsB);
    } else if (a.depth > b.depth) {
      ancestorsA.add(a.parent);
      return _pathsToCommonAncestor(a.parent, b, ancestorsA, ancestorsB);
    }

    ancestorsA.add(a.parent);
    ancestorsB.add(b.parent);
    return _pathsToCommonAncestor(a.parent, b.parent, ancestorsA, ancestorsB);
  }

  bool _debugCheckLeaderBeforeFollower(
    List<ContainerLayer> leaderToCommonAncestor,
    List<ContainerLayer> followerToCommonAncestor,
  ) {
    if (followerToCommonAncestor.length <= 1) {
      return false;
    }
    if (leaderToCommonAncestor.length <= 1) {
      return true;
    }

    final ContainerLayer leaderSubtreeBelowAncestor = leaderToCommonAncestor[leaderToCommonAncestor.length - 2];
    final ContainerLayer followerSubtreeBelowAncestor = followerToCommonAncestor[followerToCommonAncestor.length - 2];

    Layer? sibling = leaderSubtreeBelowAncestor;
    while (sibling != null) {
      if (sibling == followerSubtreeBelowAncestor) {
        return true;
      }
      sibling = sibling.nextSibling;
    }
    return false;
  }

  void _establishTransform() {
    _lastTransform = null;
    final LeaderLayer? leader = link.leader;
    if (leader == null) {
      return;
    }
    assert(
      leader.owner == owner,
      'Linked LeaderLayer anchor is not in the same layer tree as the FollowerLayer.',
    );

    final List<ContainerLayer> forwardLayers = <ContainerLayer>[leader];
    final List<ContainerLayer> inverseLayers = <ContainerLayer>[this];

    final Layer? ancestor = _pathsToCommonAncestor(
      leader,
      this,
      forwardLayers,
      inverseLayers,
    );
    assert(
      ancestor != null,
      'LeaderLayer and FollowerLayer do not have a common ancestor.',
    );
    assert(
      _debugCheckLeaderBeforeFollower(forwardLayers, inverseLayers),
      'LeaderLayer anchor must come before FollowerLayer in paint order, but the reverse was true.',
    );

    final Matrix4 forwardTransform = _collectTransformForLayerChain(forwardLayers);

    assert(forwardTransform[0] == forwardTransform[5]);

    final targetTransformScale = followScaleTransform ? 1.0 : forwardTransform[0];

    leader.applyTransform(null, forwardTransform);
    _lastLinkedOffset = leaderSize == null
        ? inputOffset
        : leaderAnchor.alongSize(leaderSize!) -
            followerAnchor.alongSize(followerSize / targetTransformScale) +
            inputOffset / targetTransformScale;
    forwardTransform.translate(_lastLinkedOffset!.dx, _lastLinkedOffset!.dy);

    final Matrix4 inverseTransform = _collectTransformForLayerChain(inverseLayers);

    if (inverseTransform.invert() == 0.0) {
      return;
    }

    if (!followScaleTransform) {
      forwardTransform[0] = 1;
      forwardTransform[5] = 1;
    }

    inverseTransform.multiply(forwardTransform);
    _lastTransform = inverseTransform;
    _inverseDirty = true;
  }

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    assert(showWhenUnlinked != null);
    if (link.leader == null && !showWhenUnlinked!) {
      _lastTransform = null;
      _lastOffset = null;
      _inverseDirty = true;
      engineLayer = null;
      return;
    }
    _establishTransform();
    if (_lastTransform != null) {
      _lastOffset = unlinkedOffset;
      engineLayer = builder.pushTransform(
        _lastTransform!.storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
      addChildrenToScene(builder);
      builder.pop();
    } else {
      _lastOffset = null;
      final Matrix4 matrix = Matrix4.translationValues(unlinkedOffset!.dx, unlinkedOffset!.dy, .0);
      engineLayer = builder.pushTransform(
        matrix.storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
      addChildrenToScene(builder);
      builder.pop();
    }
    _inverseDirty = true;
  }

  @override
  void applyTransform(Layer? child, Matrix4 transform) {
    assert(child != null);
    if (_lastTransform != null) {
      transform.multiply(_lastTransform!);
    } else {
      transform.multiply(Matrix4.translationValues(unlinkedOffset!.dx, unlinkedOffset!.dy, 0));
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LayerLink>('link', link));
    properties.add(TransformProperty('transform', getLastTransform(), defaultValue: null));
  }
}
