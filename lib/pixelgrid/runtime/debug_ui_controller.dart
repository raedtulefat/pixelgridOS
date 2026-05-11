import 'package:meta/meta.dart';

@immutable
class DebugUiState {
  const DebugUiState({
    this.grid = false,
    this.floorHighlights = false,
    this.wallHighlights = false,
    this.walkables = false,
    this.tileInfo = false,
    this.healthBars = false,
    this.playerTileHighlight = false,
    this.pathFinder = false,
    this.actorTouchBounds = false,
  });

  final bool grid;
  final bool floorHighlights;
  final bool wallHighlights;
  final bool walkables;
  final bool tileInfo;
  final bool healthBars;
  final bool playerTileHighlight;
  final bool pathFinder;
  final bool actorTouchBounds;

  static const DebugUiState allEnabled = DebugUiState(
    grid: true,
    floorHighlights: true,
    wallHighlights: true,
    walkables: true,
    tileInfo: true,
    healthBars: true,
    playerTileHighlight: true,
    pathFinder: true,
    actorTouchBounds: true,
  );

  bool get anyEnabled =>
      grid ||
      floorHighlights ||
      wallHighlights ||
      walkables ||
      tileInfo ||
      healthBars ||
      playerTileHighlight ||
      pathFinder ||
      actorTouchBounds;

  DebugUiState copyWith({
    bool? grid,
    bool? floorHighlights,
    bool? wallHighlights,
    bool? walkables,
    bool? tileInfo,
    bool? healthBars,
    bool? playerTileHighlight,
    bool? pathFinder,
    bool? actorTouchBounds,
  }) {
    return DebugUiState(
      grid: grid ?? this.grid,
      floorHighlights: floorHighlights ?? this.floorHighlights,
      wallHighlights: wallHighlights ?? this.wallHighlights,
      walkables: walkables ?? this.walkables,
      tileInfo: tileInfo ?? this.tileInfo,
      healthBars: healthBars ?? this.healthBars,
      playerTileHighlight: playerTileHighlight ?? this.playerTileHighlight,
      pathFinder: pathFinder ?? this.pathFinder,
      actorTouchBounds: actorTouchBounds ?? this.actorTouchBounds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DebugUiState &&
        other.grid == grid &&
        other.floorHighlights == floorHighlights &&
        other.wallHighlights == wallHighlights &&
        other.walkables == walkables &&
        other.tileInfo == tileInfo &&
        other.healthBars == healthBars &&
        other.playerTileHighlight == playerTileHighlight &&
        other.pathFinder == pathFinder &&
        other.actorTouchBounds == actorTouchBounds;
  }

  @override
  int get hashCode => Object.hash(
        grid,
        floorHighlights,
        wallHighlights,
        walkables,
        tileInfo,
        healthBars,
        playerTileHighlight,
        pathFinder,
        actorTouchBounds,
      );
}

enum DebugUiLayer {
  grid,
  floorHighlights,
  wallHighlights,
  walkables,
  tileInfo,
  healthBars,
  playerTileHighlight,
  pathFinder,
  actorTouchBounds,
}
