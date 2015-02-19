#!/usr/bin/env bash
set -e

if [ -e /unhealthy ]
then
  exit 2
fi
