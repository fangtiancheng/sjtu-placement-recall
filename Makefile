# 分流考回忆题 —— 构建入口
#
# 用法:
#   make            构建 2024、2025、2026 三套试题
#   make 24         只构建 2024
#   make 25         只构建 2025
#   make 26         只构建 2026
#   make check      检查 TeX 环境
#   make clean      删除中间文件
#   make distclean  删除中间文件和 dist/ 下的 PDF
#
# 依赖:
#   - TeX Live 2023 或更高版本（XeLaTeX + latexmk）
#   - 中文字体（Windows 下使用宋体/黑体；Linux 下可用 Fandol）
#   - bash（Windows 下由 Git Bash 提供）
#
# 说明:
#   具体构建逻辑放在 scripts/build.sh 中，这样既能在 Unix 下运行，
#   也能在 Windows 下运行。exam-zh 文档类要求较新的 LaTeX 内核
#   （含 hook 机制），TeX Live 2020 无法编译。

# Windows 下必须显式使用 Git for Windows 自带的 bash。
# PowerShell 里的 `bash` 可能解析到 WSL 的启动器，未安装 WSL 时会直接报错。
ifeq ($(OS),Windows_NT)
  GIT_EXEC_PATH := $(shell git --exec-path)
  GIT_ROOT := $(patsubst %/mingw64/libexec/git-core,%,$(patsubst %/mingw32/libexec/git-core,%,$(subst \,/,$(GIT_EXEC_PATH))))
  ifneq ($(strip $(GIT_ROOT)),)
    BASH := $(GIT_ROOT)/bin/bash.exe
  else
    BASH := bash
  endif
else
  BASH := bash
endif

.PHONY: all 24 25 26 2024 2025 2026 check clean distclean help

all: 24 25 26

24 2024:
	"$(BASH)" scripts/build.sh 2024

25 2025:
	"$(BASH)" scripts/build.sh 2025

26 2026:
	"$(BASH)" scripts/build.sh 2026

check:
	"$(BASH)" scripts/build.sh check

clean:
	"$(BASH)" scripts/build.sh clean

distclean:
	"$(BASH)" scripts/build.sh distclean

help:
	"$(BASH)" scripts/build.sh help
