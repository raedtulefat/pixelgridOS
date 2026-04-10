import 'package:meta/meta.dart';

@immutable
class DebugUiState {
  const DebugUiState({
    this.grid = false,
    this.floorHighlights = false,
    this.wallHighlights = false,
    this.walkables = false,
    this.tileInfo = false,
    this.infoText = false,
    this.healthBars = false,
    this.playerTileHighlight = false,
    this.pathFinder = false,
    this.shellLogs = false,
    this.surfaceOutline = false,
    this.actorTouchBounds = false,
  });

  final bool grid;
  final bool floorHighlights;
  final bool wallHighlights;
  final bool walkables;
  final bool tileInfo;
  final bool infoText;
  final bool healthBars;
  final bool playerTileHighlight;
  final bool pathFinder;
  final bool shellLogs;
  final bool surfaceOutline;
  final bool actorTouchBounds;

  static const DebugUiState allEnabled = DebugUiState(
    grid: true,
    floorHighlights: true,
    wallHighlights: true,
    walkables: true,
    tileInfo: true,
    infoText: true,
    healthBars: true,
    playerTileHighlight: true,
    pathFinder: true,
    shellLogs: true,
    surfaceOutline: true,
    actorTouchBounds: true,
  );

  bool get anyEnabled =>
      grid ||
      floorHighlights ||
      wallHighlights ||
      walkables ||
      tileInfo ||
      infoText ||
      healthBars ||
      playerTileHighlight ||
      pathFinder ||
      shellLogs ||
      surfaceOutline ||
      actorTouchBounds;

  DebugUiState copyWith({
    bool? grid,
    bool? floorHighlights,
    bool? wallHighlights,
    bool? walkables,
    bool? tileInfo,
    bool? infoText,
    bool? healthBars,
    bool? playerTileHighlight,
    bool? pathFinder,
    bool? shellLogs,
    bool? surfaceOutline,
    bool? actorTouchBounds,
  }) {
    return DebugUiState(
      grid: grid ?? this.grid,
      floorHighlights: floorHighlights ?? this.floorHighlights,
      wallHighlights: wallHighlights ?? this.wallHighlights,
      walkables: walkables ?? this.walkables,
      tileInfo: tileInfo ?? this.tileInfo,
      infoText: infoText ?? this.infoText,
      healthBars: healthBars ?? this.healthBars,
      playerTileHighlight: playerTileHighlight ?? this.playerTileHighlight,
      pathFinder: pathFinder ?? this.pathFinder,
      shellLogs: shellLogs ?? this.shellLogs,
      surfaceOutline: surfaceOutline ?? this.surfaceOutline,
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
        other.infoText == infoText &&
        other.healthBars == healthBars &&
        other.playerTileHighlight == playerTileHighlight &&
        other.pathFinder == pathFinder &&
        other.shellLogs == shellLogs &&
        other.surfaceOutline == surfaceOutline &&
        other.actorTouchBounds == actorTouchBounds;
  }

  @override
  int get hashCode => Object.hash(
        grid,
        floorHighlights,
        wallHighlights,
        walkables,
        tileInfo,
        infoText,
        healthBars,
        playerTileHighlight,
        pathFinder,
        shellLogs,
        surfaceOutline,
        actorTouchBounds,
      );
}

enum DebugUiLayer {
  grid,
  floorHighlights,
  wallHighlights,
  walkables,
  tileInfo,
  infoText,
  healthBars,
  playerTileHighlight,
  pathFinder,
  shellLogs,
  surfaceOutline,
  actorTouchBounds,
}
