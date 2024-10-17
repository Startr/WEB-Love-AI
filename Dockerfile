# syntax=docker/dockerfile:1

FROM startr/ai-web-openwebui:latest as build

# Use args
ARG USE_CUDA
ARG USE_OLLAMA
ARG USE_CUDA_VER
ARG USE_EMBEDDING_MODEL
ARG USE_RERANKING_MODEL

## Basis ##
ENV ENV=prod \
    PORT=8080 \
    # pass build args to the build
    USE_OLLAMA_DOCKER=${USE_OLLAMA} \
    USE_CUDA_DOCKER=${USE_CUDA} \
    USE_CUDA_DOCKER_VER=${USE_CUDA_VER} \
    USE_EMBEDDING_MODEL_DOCKER=${USE_EMBEDDING_MODEL} \
    USE_RERANKING_MODEL_DOCKER=${USE_RERANKING_MODEL}

## Basis URL Config ##
ENV OLLAMA_BASE_URL="/ollama" \
    OPENAI_API_BASE_URL=""

## API Key and Security Config ##
#ENV OPENAI_API_KEY="" \
#    WEBUI_SECRET_KEY="" \
#    SCARF_NO_ANALYTICS=true \
#    DO_NOT_TRACK=true \
#    ANONYMIZED_TELEMETRY=false

# Use locally bundled version of the LiteLLM cost map json
# to avoid repetitive startup connections
ENV LITELLM_LOCAL_MODEL_COST_MAP="True"


#### Other models #########################################################
## whisper TTS model settings ##
ENV WHISPER_MODEL="base" \
    WHISPER_MODEL_DIR="/app/backend/data/cache/whisper/models"

## RAG Embedding model settings ##
ENV RAG_EMBEDDING_MODEL="$USE_EMBEDDING_MODEL_DOCKER" \
    RAG_RERANKING_MODEL="$USE_RERANKING_MODEL_DOCKER" \
    SENTENCE_TRANSFORMERS_HOME="/app/backend/data/cache/embedding/models"

## Hugging Face download cache ##
ENV HF_HOME="/app/backend/data/cache/embedding/models"
#### Other models ##########################################################

WORKDIR /app/backend

RUN find . -type f -exec sed -i 's|Open WebUI|Canadians.Love/AI|g' {} +
RUN find . -name "*.js" -type f -exec sed -i 's|locally hosted|private|g' {} + \
  -exec sed -i 's|lokal gehosteten|privat|g' {} + \
  -exec sed -i 's|lokaal gehoste|privé|g' {} + \
  -exec sed -i 's|hébergé localement|privé|g' {} + \
  -exec sed -i 's|로컬에서 호스팅되는 서버에|개인 서버에|g' {} + \
  -exec sed -i 's|データはローカルでホストされているサーバー|プライベートサーバー|g' {} + \
  -exec sed -i 's|هیچ اتصال خارجی ایجاد نمی کند و داده های شما به طور ایمن در سرور میزبان محلی شما باقی می ماند.|خصوصی|g' {} + \
  -exec sed -i 's|ადგილობრივ სერვერზე|პრივატული|g' {} + \
  -exec sed -i 's|lưu trữ cục bộ|riêng tư|g' {} + \
  -exec sed -i 's|lokalnie hostowanym|prywatnie|g' {} + \
  -exec sed -i 's|alojado localmente|privado|g' {} + \
  -exec sed -i 's|hospedado localmente|privado|g' {} + \
  -exec sed -i 's|的本地服|私人的|g' {} + \
  -exec sed -i 's|локално назначен|частный|g' {} +

#COPY static/favicon.png /app/backend/static/favicon.png
#COPY static/favicon.png /app/build/favicon.png
#COPY static/favicon.png /app/favicon.png
# COPY static/assets/ /app/build/_app/immutable/assets/

#COPY backend/main.py /app/backend/open_webui/main.py

ENV HOME=/root

EXPOSE 8080

HEALTHCHECK CMD curl --silent --fail http://localhost:8080/health | jq -e '.status == true' || exit 1

USER $UID:$GID

ARG BUILD_HASH
ENV WEBUI_BUILD_VERSION=${BUILD_HASH}


# TODO Add Auto backup restore for Docker 
#
# backup /app/backend/data 
#
# Use style as https://snap.startr.cloud 
# https://github.com/opencoca/WEB-SnapCloud


CMD [ "bash", "restore_backup_start.sh", "server" ]
