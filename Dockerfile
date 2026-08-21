# AutoMem packaged for Railway.
#
# Two things the upstream image leaves to the deployer, both of which fail
# quietly on Railway:
#
#  1. With no VOYAGE_API_KEY / OPENAI_API_KEY (the default), AutoMem's "auto"
#     provider chain falls through to fastembed, which downloads
#     BAAI/bge-large-en-v1.5 (~1.2 GB) at container start into
#     ~/.config/automem/models. On Railway that directory is on the disposable
#     layer, so every deploy pays the download again, and if it fails the chain
#     falls through once more to the placeholder provider -- deterministic
#     sha256 noise vectors, which store and recall without an error while
#     returning semantically meaningless results.
#
#  2. Nothing pins the provider, so that degradation is invisible.
#
# This image bakes the model into the image (outside any volume mount, because
# a Railway volume is a bind mount that hides image-built files) and pins
# EMBEDDING_PROVIDER=local, which raises instead of falling through.
FROM ghcr.io/verygoodplugins/automem:0.16.1

ENV AUTOMEM_MODELS_DIR=/opt/automem/models \
    EMBEDDING_PROVIDER=local \
    VECTOR_SIZE=1024

RUN python - <<'PY'
import os
from pathlib import Path
os.environ["AUTOMEM_MODELS_DIR"] = "/opt/automem/models"
from automem.embedding.fastembed import FastEmbedProvider
p = FastEmbedProvider(dimension=1024)
vec = p.generate_embedding("railway build-time warmup")
assert len(vec) == 1024, len(vec)
assert p.provider_name().startswith("fastembed"), p.provider_name()
cached = list(Path("/opt/automem/models").iterdir())
assert cached, "model cache is empty"
print("baked", p.provider_name(), "->", [d.name for d in cached])
PY

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 8001
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["python", "app.py"]
