# automem-railway

Wrapper images that package [AutoMem](https://github.com/verygoodplugins/automem) —
the graph + vector memory service for AI agents — for Railway.

Two images:

| image | base | what the wrapper changes |
|---|---|---|
| `ghcr.io/bon5co/automem-railway:0.16.1` | `ghcr.io/verygoodplugins/automem:0.16.1` | bakes the `BAAI/bge-large-en-v1.5` embedding model into the image and pins `EMBEDDING_PROVIDER=local`, so a deploy with no hosted embedding key neither downloads 1.2 GB at every container start nor silently degrades to hash-based placeholder vectors; refuses to boot without `AUTOMEM_API_TOKEN` |
| `ghcr.io/bon5co/automem-railway-falkordb:v4.20.4` | `falkordb/falkordb:v4.20.4` | appends `--requirepass "$FALKOR_PASSWORD"` so the generated password is actually enforced (upstream ignores the variable), disables the bundled Next.js graph browser, refuses to boot on an empty password |

## Why

AutoMem's embedding provider chain is Voyage → OpenAI → Ollama → fastembed →
placeholder (`automem/embedding/provider_init.py`). A deploy with no API keys
lands on fastembed, which downloads `BAAI/bge-large-en-v1.5` (~1.2 GB) into
`~/.config/automem/models` at container start. On Railway that path is on the
disposable layer, so the download repeats on every deploy — and when it fails
the chain falls through once more to `PlaceholderEmbeddingProvider`, which
returns `random.Random(sha256(text))` vectors. Stores succeed, recalls succeed,
`/health` reports `healthy`, and the results are noise.

FalkorDB's image never reads `FALKOR_PASSWORD`; only `REDIS_ARGS` reaches
`redis-server`. Passing the password to the API service without
`--requirepass` on the server leaves the graph unauthenticated.

Both images are used by the Railway template published from
[bon5co/railwaytemplate2](https://github.com/bon5co/railwaytemplate2).
