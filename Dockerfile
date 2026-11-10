# zikai decisions-API image — sys-k58vym.2
#
# Source is UPSTREAM at a pinned sha, baked in: the build context is a checkout
# of https://github.com/jacobhausler/zikai at
# UPSTREAM_SHA=9607ab5f3e25decee66676ba650b577b1ac6b965
# (git -C <ctx> rev-parse HEAD proves it; the image tag carries the short sha).
# `pip install .` lands the package in site-packages; /app stays the checkout
# tree. Upstream packaging ships only the zikai/ python package (no data/,
# pipeline/, dashboard/), so the serve paths are pinned to the checkout copy
# via ZIKAI_* — one source of truth for the corpus, in /app.
#
# Writable state (bead sys-k58vym.2 decision): deploy mounts ONE writable git
# checkout (host volume or CSI) at /app — the nightly `zikai nightly --push`
# needs a git-pushable tree and rewrites data/ in place, so the checkout and
# data/ ride together. With no mount the image serves the baked /app/data
# (read-only). Dashboard assets are not packaged upstream — serve with
# ZIKAI_DASHBOARD=false until the deploy bead wires them.
# Serve-only image: no git here — the nightly runs from the mounted checkout
# with its own venv, not from this image.
FROM python:3.12-slim

COPY . /app
WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    ZIKAI_REQUIRE_KEY=false \
    ZIKAI_DASHBOARD=false \
    ZIKAI_CORPUS_PATH=/app/data/corpus.json \
    ZIKAI_TREE_PATH=/app/data/decision_tree.json

RUN pip install --no-cache-dir .

EXPOSE 8077

ENTRYPOINT ["zikai", "serve"]
