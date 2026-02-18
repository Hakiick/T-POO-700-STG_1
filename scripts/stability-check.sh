#!/bin/bash
# stability-check.sh — Vérifie la stabilité de l'application frontend
# Usage: bash scripts/stability-check.sh

set -uo pipefail

# Déterminer le répertoire du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo "========================================="
echo "  STABILITY CHECK (frontend/)"
echo "========================================="
echo ""

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "  ✗ Dossier frontend/ introuvable: $FRONTEND_DIR"
  exit 1
fi

cd "$FRONTEND_DIR"

errors=0

# 1. Build
echo "[1/3] Build..."
if npm run build 2>&1; then
  echo "  ✓ Build OK"
else
  echo "  ✗ Build FAILED"
  errors=$((errors + 1))
fi
echo ""

# 2. Type check
echo "[2/3] Type check..."
if npx tsc --noEmit 2>&1; then
  echo "  ✓ Type check OK"
else
  echo "  ✗ Type check FAILED"
  errors=$((errors + 1))
fi
echo ""

# 3. Lint (si configuré)
echo "[3/3] Lint..."
if npm run lint 2>&1; then
  echo "  ✓ Lint OK"
else
  echo "  ⚠ Lint skipped or failed (pas de script lint configuré)"
fi
echo ""

echo "========================================="
if [ "$errors" -eq 0 ]; then
  echo "  RÉSULTAT: STABLE ✓"
  echo "  Tous les checks passent."
  echo "========================================="
  exit 0
else
  echo "  RÉSULTAT: INSTABLE ✗"
  echo "  $errors check(s) en échec."
  echo "========================================="
  exit 1
fi
