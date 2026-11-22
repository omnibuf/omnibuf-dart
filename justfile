# List available recipes
default:
    @just --list

# Install Dart dependencies
install:
    dart pub get

# Build AOT native binaries (protoc plugin, conformance adapter, benchmark runner)
build:
    dart compile exe bin/protoc-gen-omnibuf-dart.dart -o bin/protoc-gen-omnibuf-dart
    dart compile exe bin/conformance_dart.dart -o bin/conformance_dart
    dart compile exe benchmark/peer_update_bench.dart -o bin/bench_dart

# Lint Protobuf schemas and regenerate Tier 1 Dart code via buf + protoc-gen-omnibuf-dart
proto:
    buf lint
    dart compile exe bin/protoc-gen-omnibuf-dart.dart -o bin/protoc-gen-omnibuf-dart
    buf generate
    dart format lib/src/generated

# Run Dart unit and integration tests
test:
    dart test

# Run the cross-language OmniBuf conformance suite across all 4 tiers
conformance:
    #!/usr/bin/env bash
    set -euo pipefail
    dart compile exe bin/conformance_dart.dart -o bin/conformance_dart
    if [[ -n "${CONFORMANCE_RUNNER:-}" ]]; then
        RUNNER="$CONFORMANCE_RUNNER"
    elif [[ -x "../omnibuf-go/bin/conformance-runner" ]]; then
        RUNNER="../omnibuf-go/bin/conformance-runner"
    elif command -v conformance-runner >/dev/null 2>&1; then
        RUNNER="conformance-runner"
    else
        echo "conformance-runner binary not found; set CONFORMANCE_RUNNER or install conformance-runner" >&2
        exit 1
    fi
    "$RUNNER" ./bin/conformance_dart

# Run the AOT PeerUpdate benchmark suite and write testdata/benchmarks.json
bench:
    dart compile exe benchmark/peer_update_bench.dart -o bin/bench_dart
    ./bin/bench_dart

# Run static analysis and Protobuf lint
lint:
    dart analyze --fatal-infos
    buf lint

# Format Dart and Protobuf files in place
fmt:
    dart format .
    buf format -w

# Check Dart and Protobuf formatting without modifying files
fmt-check:
    dart format --output=none --set-exit-if-changed .
    buf format -d --exit-code

# Run the complete CI verification pipeline
ci: fmt-check lint build test conformance
