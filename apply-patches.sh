#!/bin/bash
# ==============================================================================
# LineageOS 23.2 (Android 16) - Custom Tweaks & Patches for Xiaomi lisa
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINEAGE_ROOT="${2:-/mnt/ssd/lineage}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

PROJECTS=(
    "device/xiaomi/lisa:device_xiaomi_lisa"
    "device/xiaomi/sm8350-common:device_xiaomi_sm8350-common"
    "frameworks/base:frameworks_base"
    "kernel/xiaomi/sm8350:kernel_xiaomi_sm8350"
    "packages/apps/Settings:packages_apps_Settings"
)

apply_patches() {
    log_info "Applying patches to LineageOS source tree at $LINEAGE_ROOT..."

    if [ ! -d "$LINEAGE_ROOT/build" ]; then
        log_error "LineageOS root not found at '$LINEAGE_ROOT'."
        exit 1
    fi

    for entry in "${PROJECTS[@]}"; do
        rel_path="${entry%%:*}"
        patch_dir_name="${entry##*:}"
        full_proj_dir="$LINEAGE_ROOT/$rel_path"
        full_patch_dir="$SCRIPT_DIR/patches/$patch_dir_name"

        if [ ! -d "$full_proj_dir" ]; then
            log_warn "Project directory $rel_path not found, skipping."
            continue
        fi

        log_info "Processing $rel_path..."
        cd "$full_proj_dir"

        # Ensure we are on my-tweaks branch
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        if [ "$current_branch" != "my-tweaks" ]; then
            if git show-ref --verify --quiet refs/heads/my-tweaks; then
                git checkout my-tweaks
            else
                git checkout -b my-tweaks
            fi
        fi

        for patch_file in "$full_patch_dir"/*.patch; do
            [ -e "$patch_file" ] || continue
            patch_name="$(basename "$patch_file")"
            subject="$(git mailinfo /dev/null /dev/null < "$patch_file" | sed -n 's/^Subject: //p')"

            # Check if this patch subject already exists in git log
            if git log -n 50 --format="%s" | grep -F -x "$subject" >/dev/null 2>&1; then
                log_ok "  [SKIP] '$subject' already applied."
            else
                log_info "  [APPLY] $patch_name ($subject)"
                if git am --3way "$patch_file"; then
                    log_ok "  Applied: $subject"
                else
                    log_error "Failed to apply $patch_file!"
                    git am --abort 2>/dev/null || true
                    exit 1
                fi
            fi
        done
    done

    log_ok "All patches applied successfully!"
}

export_patches() {
    log_info "Exporting current my-tweaks commits into patches directory..."

    if [ ! -d "$LINEAGE_ROOT/build" ]; then
        log_error "LineageOS root not found at '$LINEAGE_ROOT'."
        exit 1
    fi

    for entry in "${PROJECTS[@]}"; do
        rel_path="${entry%%:*}"
        patch_dir_name="${entry##*:}"
        full_proj_dir="$LINEAGE_ROOT/$rel_path"
        full_patch_dir="$SCRIPT_DIR/patches/$patch_dir_name"

        [ -d "$full_proj_dir" ] || continue
        cd "$full_proj_dir"

        rm -f "$full_patch_dir"/*.patch
        mkdir -p "$full_patch_dir"
        git format-patch -o "$full_patch_dir" github/lineage-23.2..my-tweaks >/dev/null
        count=$(ls -1 "$full_patch_dir"/*.patch 2>/dev/null | wc -l)
        log_ok "Exported $count patches for $rel_path"
    done

    log_ok "Export completed! Ready to git commit & push in $SCRIPT_DIR."
}

case "$1" in
    --export)
        export_patches
        ;;
    *)
        apply_patches
        ;;
esac
