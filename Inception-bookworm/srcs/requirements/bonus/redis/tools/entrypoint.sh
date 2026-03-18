#!/bin/bash
set -e

echo "Starting Redis..."

exec redis-server --bind 0.0.0.0 --protected-mode no