# FalkorDB packaged for Railway.
#
# Two upstream defaults that matter on a hosted memory service:
#
#  1. The image does not read FALKOR_PASSWORD. It passes REDIS_ARGS through to
#     redis-server verbatim, so a template that generates a password and hands
#     it to the API service still boots a graph database that logs
#       "WARNING: Redis does not require authentication ..."
#     and answers every command from anything that can reach it.
#  2. BROWSER defaults to 1, so a Next.js graph browser runs on :3000 in every
#     container whether or not anybody asked for it.
FROM falkordb/falkordb:v4.20.4

ENV BROWSER=0

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD []
