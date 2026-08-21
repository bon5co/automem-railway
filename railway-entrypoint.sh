#!/bin/sh
# Fail fast on the two configurations that produce a healthy-looking AutoMem
# with no working memory: an embedding provider that silently degrades to
# hash-based placeholder vectors, and a missing API token.
set -e

if [ -z "${AUTOMEM_API_TOKEN}" ]; then
  echo "FATAL: AUTOMEM_API_TOKEN is empty. AutoMem would accept unauthenticated" >&2
  echo "       reads and writes of every stored memory. Refusing to start." >&2
  exit 1
fi

# If the deployer supplied a hosted embedding key, let AutoMem's own auto chain
# pick it; otherwise stay on the baked local model. Either way, never fall
# through to the placeholder provider.
if [ -n "${VOYAGE_API_KEY}" ] || [ -n "${OPENAI_API_KEY}" ]; then
  export EMBEDDING_PROVIDER="${EMBEDDING_PROVIDER_OVERRIDE:-auto}"
else
  export EMBEDDING_PROVIDER="${EMBEDDING_PROVIDER_OVERRIDE:-local}"
fi

if [ ! -d "${AUTOMEM_MODELS_DIR}" ] || [ -z "$(ls -A "${AUTOMEM_MODELS_DIR}" 2>/dev/null)" ]; then
  echo "WARN: baked model cache ${AUTOMEM_MODELS_DIR} is empty" >&2
fi

echo "[railway] embedding_provider=${EMBEDDING_PROVIDER} models_dir=${AUTOMEM_MODELS_DIR} vector_size=${VECTOR_SIZE}"
exec "$@"
