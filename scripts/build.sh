#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Git Bash 下的 pwd 是 /d/... 形式，Windows 版 TeX 需要 D:/... 形式。
if [[ "${OS:-}" == "Windows_NT" ]]; then
  ROOT_TEX="$(cd "$ROOT" && pwd -W 2>/dev/null || printf '%s' "$ROOT")"
  TEXINPUTS_SEP=';'
else
  ROOT_TEX="$ROOT"
  TEXINPUTS_SEP=':'
fi

# 让 XeLaTeX / latexmk 在仓库根目录的 exam-zh/ 下找到文档类。
export TEXINPUTS="${ROOT_TEX}/exam-zh${TEXINPUTS_SEP}${TEXINPUTS:-}"

LATEXMK="${LATEXMK:-latexmk}"
BUILD_DIR="$ROOT/build"
DIST_DIR="$ROOT/dist"

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

# TeX Live 2026 的 xelatex 在 Windows 上无法把含中文的路径写入
# TEXMF_OUTPUT_DIRECTORY（putenv 会失败），因此非 ASCII 仓库路径
# 需要使用纯 ASCII 的临时输出目录。
is_non_ascii() {
  printf '%s' "$1" | LC_ALL=C grep -q '[^ -~]'
}

# 终端可能是在安装 TeX Live 之前启动的，PATH 尚未刷新。
# 这时自动到常见安装位置查找，避免要求用户重开终端。
ensure_texlive_path() {
  if command -v latexmk >/dev/null 2>&1 \
    && command -v xelatex >/dev/null 2>&1; then
    return 0
  fi

  local -a candidates=()
  local -a discovered=()
  local bin

  if [[ -n "${TEXLIVE_BIN:-}" ]]; then
    if command -v cygpath >/dev/null 2>&1; then
      candidates+=("$(cygpath -u "$TEXLIVE_BIN")")
    else
      candidates+=("$TEXLIVE_BIN")
    fi
  fi

  if [[ "${OS:-}" == "Windows_NT" ]]; then
    local drive root
    for drive in c d e f g h; do
      for root in "/$drive/texlive" "/$drive/Program Files/texlive"; do
        for bin in "$root"/*/bin/windows "$root"/*/bin/win32; do
          if [[ -d "$bin" ]]; then
            discovered+=("$bin")
          fi
        done
      done
    done
  fi

  if ((${#discovered[@]})); then
    while IFS= read -r bin; do
      candidates+=("$bin")
    done < <(printf '%s\n' "${discovered[@]}" | sort -Vr)
  fi

  if ((${#candidates[@]})); then
    for bin in "${candidates[@]}"; do
      if [[ -x "$bin/latexmk.exe" && -x "$bin/xelatex.exe" ]] \
        || [[ -x "$bin/latexmk" && -x "$bin/xelatex" ]]; then
        export PATH="$bin:$PATH"
        printf '提示：当前终端的 PATH 未包含 TeX Live，自动使用 %s\n' "$bin"
        return 0
      fi
    done
  fi

  return 1
}

check_tools() {
  ensure_texlive_path || true
  command -v "$LATEXMK" >/dev/null 2>&1 \
    || die "找不到 latexmk。请安装 TeX Live 2023 或更高版本，或设置 TEXLIVE_BIN 指向 TeX Live 的 bin 目录。"
  command -v xelatex >/dev/null 2>&1 \
    || die "找不到 xelatex。请安装 TeX Live 2023 或更高版本，或设置 TEXLIVE_BIN 指向 TeX Live 的 bin 目录。"
  [[ -f "$ROOT/exam-zh/exam-zh.cls" ]] \
    || die "缺少 exam-zh/exam-zh.cls。"

  # 提前拦截过旧的 TeX Live，避免输出大段难以理解的 LaTeX 报错。
  local xelatex_version
  xelatex_version="$(xelatex --version 2>/dev/null | head -n 1 || true)"
  if [[ "$xelatex_version" =~ TeX\ Live\ ([0-9]{4}) ]]; then
    local texlive_year="${BASH_REMATCH[1]}"
    if (( texlive_year < 2023 )); then
      die "检测到 TeX Live ${texlive_year}，exam-zh v0.2.3 需要 TeX Live 2023 或更高版本。"
    fi
  fi
}

build_year() {
  local year="$1"
  local short="${year#20}"
  local pdf="dist/${short}分流考回忆题.pdf"

  [[ -d "$ROOT/$year" ]] || die "找不到年份目录 $year。"
  [[ -f "$ROOT/$year/fenliukao.tex" ]] \
    || die "找不到 $year/fenliukao.tex。"

  check_tools

  local build_base="$BUILD_DIR"
  local temp_build=0
  if [[ "${OS:-}" == "Windows_NT" ]] && is_non_ascii "$ROOT_TEX"; then
    local tmp
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/fenliukao-XXXXXX")" \
      || die "无法创建临时构建目录。"
    if command -v cygpath >/dev/null 2>&1; then
      build_base="$(cygpath -m "$tmp")"
    else
      build_base="$tmp"
    fi
    if is_non_ascii "$build_base"; then
      die "临时构建目录包含非 ASCII 字符（$build_base），XeLaTeX 无法写入。"
    fi
    temp_build=1
    printf '提示：仓库路径包含非 ASCII 字符，构建输出改到 %s\n' "$build_base"
  fi
  local outdir="$build_base/$year"
  local classdir="$build_base/texmf"
  mkdir -p "$outdir" "$DIST_DIR" "$classdir"

  # TeX Live 2026 自带 exam-zh v0.3.6，会优先于仓库中的 v0.2.3。
  # 把仓库内的文档类复制到 ASCII 构建目录并放到 TEXINPUTS 最前面，
  # 保证三年试卷都使用同一版本。
  cp "$ROOT/exam-zh/exam-zh.cls" "$ROOT/exam-zh"/exam-zh-*.sty "$classdir/"

  printf '\n==> 构建 %s 分流考回忆题\n' "$year"
  (
    cd "$ROOT/$year"
    export TEXINPUTS="$classdir${TEXINPUTS_SEP}${TEXINPUTS:-}"
    "$LATEXMK" -xelatex -interaction=nonstopmode -halt-on-error \
      -outdir="$outdir" fenliukao.tex
  )

  [[ -f "$outdir/fenliukao.pdf" ]] \
    || die "构建结束但未生成 $outdir/fenliukao.pdf。"
  cp "$outdir/fenliukao.pdf" "$DIST_DIR/${short}分流考回忆题.pdf"
  if (( temp_build )); then
    rm -rf "$build_base"
  fi
  printf '已生成 %s\n' "$pdf"
}

do_check() {
  printf '== 构建环境检查 ==\n'
  ensure_texlive_path || true
  if command -v "$LATEXMK" >/dev/null 2>&1; then
    printf 'latexmk:  %s\n' "$(command -v "$LATEXMK")"
    "$LATEXMK" --version 2>/dev/null | head -n 1 || true
  else
    printf 'latexmk:  未找到\n'
  fi
  if command -v xelatex >/dev/null 2>&1; then
    printf 'xelatex:  %s\n' "$(command -v xelatex)"
    xelatex --version 2>/dev/null | head -n 1 || true
  else
    printf 'xelatex:  未找到\n'
  fi
  if [[ -f "$ROOT/exam-zh/exam-zh.cls" ]]; then
    printf 'exam-zh:  %s\n' "$ROOT/exam-zh/exam-zh.cls"
  else
    printf 'exam-zh:  缺少文档类文件\n'
  fi
  if command -v kpsewhich >/dev/null 2>&1; then
    local found
    found="$(kpsewhich exam-zh.cls || true)"
    printf 'kpsewhich: %s\n' "${found:-未找到 exam-zh.cls}"
  fi
  printf '\n注意：exam-zh v0.2.3 需要 TeX Live 2023 或更高版本。\n'
}

do_clean() {
  rm -rf "$BUILD_DIR"
  printf '已删除 %s\n' "$BUILD_DIR"
}

do_distclean() {
  rm -rf "$BUILD_DIR" "$DIST_DIR"
  printf '已删除 %s 和 %s\n' "$BUILD_DIR" "$DIST_DIR"
}

usage() {
  cat <<'EOF'
用法:
  scripts/build.sh 2024|2025|2026   构建某一年
  scripts/build.sh check            检查 TeX 环境
  scripts/build.sh clean            删除 build/
  scripts/build.sh distclean        删除 build/ 和 dist/
  scripts/build.sh help             显示本说明

环境变量:
  LATEXMK   指定 latexmk 命令（默认: latexmk）
EOF
}

case "${1:-help}" in
  2024|2025|2026)
    build_year "$1"
    ;;
  check)
    do_check
    ;;
  clean)
    do_clean
    ;;
  distclean)
    do_distclean
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
