{ config, lib, pkgs, ... }:

let
  version = "b10970";
  modelId = "muse-glimmer-30b";
  modelDir = "${config.home.homeDirectory}/models/muse-glimmer-30b";
  modelPath = "${modelDir}/muse-glimmer-30B-kquant-dynamic.gguf";
  draftPath = "${modelDir}/dflash-kquant.gguf";
  endpoint = "http://127.0.0.1:8080";
  launchdLabel = "org.nix-community.home.local-llm";

  # Pin an official llama.cpp binary new enough for Muse Glimmer and DFlash.
  # An explicit build keeps the model/runtime pair reproducible across switches.
  llama-cpp-bin = pkgs.stdenvNoCC.mkDerivation {
    pname = "llama-cpp-bin";
    inherit version;

    src = pkgs.fetchzip {
      url = "https://github.com/ggml-org/llama.cpp/releases/download/${version}/llama-${version}-bin-macos-arm64.tar.gz";
      hash = "sha256-h5bJbJJDcWxZWwJRmh1YUTOQlcApNh/toeUvugVQ6Sw=";
    };

    dontBuild = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/llama-cpp" "$out/bin"
      cp -R . "$out/lib/llama-cpp/"

      for f in "$out"/lib/llama-cpp/*; do
        name=$(basename "$f")
        case "$name" in
          *.dylib|*.metal|LICENSE*) continue ;;
        esac
        if [ -f "$f" ] && [ -x "$f" ]; then
          makeWrapper "$f" "$out/bin/$name"
        fi
      done

      runHook postInstall
    '';
  };

  local-llm = pkgs.writeShellApplication {
    name = "local-llm";
    runtimeInputs = [ pkgs.coreutils pkgs.curl pkgs.jq ];
    text = ''
      label=${launchdLabel}
      service="gui/$(id -u)/$label"
      endpoint=${endpoint}
      api_key=local-only
      model_id=${modelId}
      model_path=${modelPath}
      draft_path=${draftPath}
      log_path=${config.home.homeDirectory}/Library/Logs/local-llm.log
      error_log_path=${config.home.homeDirectory}/Library/Logs/local-llm.error.log

      health() {
        curl --fail --silent --show-error --max-time 2 \
          -H "Authorization: Bearer $api_key" \
          "$endpoint/health"
      }

      wait_until_ready() {
        attempts=0
        until health >/dev/null 2>&1; do
          attempts=$((attempts + 1))
          if [ "$attempts" -ge 120 ]; then
            echo "local-llm did not become ready; inspect: local-llm logs" >&2
            return 1
          fi
          sleep 1
        done
      }

      start() {
        if health >/dev/null 2>&1; then
          echo "local-llm is already ready at $endpoint"
          return 0
        fi
        if ! launchctl print "$service" >/dev/null 2>&1; then
          echo "launchd service is not loaded; run home-manager switch first" >&2
          return 1
        fi
        launchctl kickstart -k "$service"
        echo "loading $model_id (this can take several seconds)..."
        wait_until_ready
        echo "local-llm is ready at $endpoint"
      }

      case "''${1:-status}" in
        serve|serve-dflash)
          test -r "$model_path" || { echo "missing model: $model_path" >&2; exit 1; }
          speculative_args=()
          if [ "$1" = serve-dflash ]; then
            test -r "$draft_path" || { echo "missing DFlash draft: $draft_path" >&2; exit 1; }
            speculative_args=(
              --model-draft "$draft_path"
              --spec-type "draft-dflash,ngram-mod"
              --spec-draft-n-max 8
              --spec-ngram-mod-n-match 24
              --spec-ngram-mod-n-min 24
              --spec-ngram-mod-n-max 64
              --cache-type-k-draft q8_0
              --cache-type-v-draft q8_0
            )
          fi
          exec ${llama-cpp-bin}/bin/llama-server \
            --model "$model_path" \
            --alias "$model_id" \
            "''${speculative_args[@]}" \
            --n-gpu-layers 999 \
            --ctx-size 32768 \
            --parallel 1 \
            --flash-attn on \
            --cache-type-k q8_0 \
            --cache-type-v q8_0 \
            --cache-ram 2048 \
            --cache-reuse 256 \
            --metrics \
            --slots \
            --jinja \
            --api-key "$api_key" \
            --cors-origins http://127.0.0.1,http://localhost \
            --host 127.0.0.1 \
            --port 8080
          ;;
        start)
          start
          ;;
        stop)
          if launchctl print "$service" >/dev/null 2>&1; then
            launchctl kill SIGTERM "$service" 2>/dev/null || true
          fi
          echo "local-llm stopped"
          ;;
        restart)
          launchctl kill SIGTERM "$service" 2>/dev/null || true
          start
          ;;
        status)
          if health >/dev/null 2>&1; then
            curl --fail --silent \
              -H "Authorization: Bearer $api_key" \
              "$endpoint/v1/models" \
              | jq '{status: "ready", models: [.data[].id]}'
          else
            echo "local-llm is stopped or still loading"
            exit 1
          fi
          ;;
        doctor)
          printf 'runtime: '
          ${llama-cpp-bin}/bin/llama-server --version 2>&1 | sed -n 's/^version: /llama.cpp /p' | head -n 1
          printf 'model:   '
          test -r "$model_path" && echo "ok ($model_path)" || echo "missing ($model_path)"
          printf 'draft:   '
          test -r "$draft_path" && echo "ok ($draft_path)" || echo "missing ($draft_path)"
          printf 'service: '
          launchctl print "$service" >/dev/null 2>&1 && echo loaded || echo not-loaded
          printf 'health:  '
          health >/dev/null 2>&1 && echo ready || echo stopped
          printf 'client:  '
          ${pkgs.mise}/bin/mise exec -- opencode --version 2>/dev/null || echo missing
          ;;
        logs)
          touch "$log_path" "$error_log_path"
          tail -n 100 -F "$log_path" "$error_log_path"
          ;;
        metrics)
          curl --fail --silent --show-error \
            -H "Authorization: Bearer $api_key" \
            "$endpoint/metrics"
          ;;
        bench)
          start >/dev/null
          payload=$(jq -n --arg model "$model_id" '{
            model: $model,
            messages: [{role: "user", content: "Return exactly one line containing: LOCAL_LLM_OK"}],
            temperature: 0,
            max_tokens: 512,
            stream: false
          }')
          curl --fail --silent --show-error \
            -H "Authorization: Bearer $api_key" \
            -H 'Content-Type: application/json' \
            -d "$payload" \
            "$endpoint/v1/chat/completions" \
            | jq '{text: .choices[0].message.content, reasoning: .choices[0].message.reasoning_content, finish_reason: .choices[0].finish_reason, usage, timings}'
          ;;
        code)
          shift || true
          start >/dev/null
          ${pkgs.mise}/bin/mise which opencode >/dev/null 2>&1 || {
            echo "opencode is missing; run mise install" >&2
            exit 1
          }
          exec ${pkgs.mise}/bin/mise exec -- opencode --model "llama-local/$model_id" "$@"
          ;;
        *)
          echo "usage: local-llm {start|stop|restart|status|doctor|logs|metrics|bench|code|serve-dflash}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [ llama-cpp-bin local-llm ];

  launchd.agents.local-llm = {
    enable = true;
    config = {
      ProgramArguments = [ "${local-llm}/bin/local-llm" "serve" ];
      RunAtLoad = false;
      KeepAlive = false;
      ProcessType = "Interactive";
      ThrottleInterval = 10;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/local-llm.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/local-llm.error.log";
    };
  };

  # OpenCode is one of Herdr's natively detected agents. A single llama.cpp
  # slot serializes local requests instead of dividing memory bandwidth across
  # concurrent Herdr panes.
  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    model = "llama-local/${modelId}";
    provider.llama-local = {
      npm = "@ai-sdk/openai-compatible";
      name = "llama.cpp (local)";
      options = {
        baseURL = "${endpoint}/v1";
        apiKey = "local-only";
      };
      models.${modelId} = {
        name = "Muse Glimmer 30B (local)";
        limit = {
          context = 32768;
          output = 8192;
        };
      };
    };
  };

  # Herdr owns the versioned OpenCode hooks. Reinstalling on every activation
  # keeps them aligned with the Herdr version selected by mise.
  home.activation.herdrOpenCodeIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ${pkgs.mise}/bin/mise which herdr >/dev/null 2>&1; then
      ${pkgs.mise}/bin/mise exec -- herdr integration install opencode
    else
      echo "warning: Herdr is not installed; run 'mise install' to enable OpenCode integration" >&2
    fi
  '';
}
