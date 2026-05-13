#!/bin/bash -ex

python -m venv ./venv
. ./venv/bin/activate \
    && pip install -U uv \
    && uv --no-cache pip install wheel \
    && uv --no-cache pip install -r requirements.txt
