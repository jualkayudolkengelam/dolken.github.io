#!/bin/bash
# Validasi artikel post_with_city.
# Usage: ./validate-post.sh [--new] <file.md>
exec ruby "$(dirname "$0")/scripts/validate-city-post.rb" "$@"
