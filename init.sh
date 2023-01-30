#!/bin/bash
cp -f /actions-runner/* /runner
cp -r /actions-runner/* /runner
( \
    ( echo ; echo; echo; echo ) | /runner/config.sh --url "${GIT_URL}" --token "${TOKEN}" \
    && /runner/run.sh \
) \
|| /runner/run.sh || exit 0