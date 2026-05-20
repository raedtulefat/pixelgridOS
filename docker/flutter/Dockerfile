FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /workspace/pixelgridOS

EXPOSE 8080
CMD ["bash", "-lc", "flutter pub get && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 --dart-define=PI_API_URL=${PI_API_URL:-http://localhost:8787} --dart-define=PI_BRIDGE_TOKEN=${PI_BRIDGE_TOKEN:-}"]
