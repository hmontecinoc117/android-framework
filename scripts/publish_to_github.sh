#!/usr/bin/env bash
set -euo pipefail

# Publish local repo to GitHub using gh (if available) or GitHub API via GH_TOKEN.
# Usage:
#   scripts/publish_to_github.sh [--repo-name NAME] [--visibility public|private] [--org ORG] [--dry-run]
# Env vars:
#   GH_TOKEN   Personal Access Token (repo scope). If set, API fallback will be used.
#   GH_OWNER   Optional owner (user/org). If not set, owner is inferred when using GH_TOKEN.

log() { echo "[publish] $*"; }
err() { echo "[publish:ERROR] $*" >&2; }

REPO_NAME="${PWD##*/}"
VISIBILITY="public"
ORG=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-name) REPO_NAME="$2"; shift 2 ;;
    --visibility) VISIBILITY="$2"; shift 2 ;;
    --org) ORG="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) err "Unknown arg: $1"; exit 2 ;;
  esac
done

# Sanity checks
command -v git >/dev/null || { err "Git no está instalado"; exit 1; }

# Ensure repo exists and has at least one commit
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "No estás dentro de un repositorio Git"
  exit 1
fi

# Ensure branch main exists; otherwise use current
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH="main"
if [[ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]]; then
  log "Usando rama actual: $CURRENT_BRANCH (no main)"
  TARGET_BRANCH="$CURRENT_BRANCH"
fi

# If remote origin exists, just push
if git remote get-url origin >/dev/null 2>&1; then
  REMOTE_URL=$(git remote get-url origin)
  log "Remoto ya configurado: $REMOTE_URL"
  [[ "$DRY_RUN" == true ]] && { log "[dry-run] git push -u origin $TARGET_BRANCH"; exit 0; }
  git push -u origin "$TARGET_BRANCH"
  log "Push completado"
  exit 0
fi

# Try gh first if available and authenticated
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    log "Usando GitHub CLI (gh) para crear el repositorio"
    GH_FLAGS=("--source" "." "--remote" "origin" "--push")
    if [[ "$VISIBILITY" == "private" ]]; then
      GH_FLAGS+=("--private")
    else
      GH_FLAGS+=("--public")
    fi
    [[ -n "$ORG" ]] && GH_FLAGS+=("--owner" "$ORG")

    log "gh repo create $REPO_NAME ${GH_FLAGS[*]}"
    [[ "$DRY_RUN" == true ]] && { log "[dry-run] gh repo create $REPO_NAME ${GH_FLAGS[*]}"; exit 0; }
    gh repo create "$REPO_NAME" "${GH_FLAGS[@]}"
    log "Repo creado y push realizado con gh"
    exit 0
  else
    log "gh instalado pero no autenticado; intentando fallback con GH_TOKEN"
  fi
fi

# Fallback: GitHub API using GH_TOKEN
if [[ -z "${GH_TOKEN:-}" ]]; then
  err "GH_TOKEN no definido. Exporta un token con scope 'repo' o autentica gh."
  err "Ejemplo: export GH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxx"
  exit 1
fi

API="https://api.github.com"
OWNER="${GH_OWNER:-}"

# Infer owner from token if not provided
if [[ -z "$OWNER" ]]; then
  OWNER=$(curl -fsSL -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github+json" "$API/user" | sed -n 's#.*"login":"\([^"]\+\)".*#\1#p')
  [[ -z "$OWNER" ]] && { err "No se pudo inferir el usuario desde GH_TOKEN"; exit 1; }
fi

# Create repo via API (user or org)
CREATE_URL="$API/user/repos"
if [[ -n "$ORG" ]]; then
  CREATE_URL="$API/orgs/$ORG/repos"
  OWNER="$ORG"
fi

DATA=$(jq -nc --arg name "$REPO_NAME" --arg vis "$VISIBILITY" --arg desc "Android + Godot framework" '{name:$name, private:($vis=="private"), description:$desc}')

log "Creando repo via API para owner=$OWNER name=$REPO_NAME visibility=$VISIBILITY"
[[ "$DRY_RUN" == true ]] && { log "[dry-run] POST $CREATE_URL payload=$DATA"; log "[dry-run] git remote add origin https://github.com/$OWNER/$REPO_NAME.git"; log "[dry-run] git push -u origin $TARGET_BRANCH"; exit 0; }

curl -fsSL -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github+json" -d "$DATA" "$CREATE_URL" >/dev/null

git remote add origin "https://github.com/$OWNER/$REPO_NAME.git"
log "Remoto configurado: https://github.com/$OWNER/$REPO_NAME.git"

git push -u origin "$TARGET_BRANCH"
log "Push completado"
