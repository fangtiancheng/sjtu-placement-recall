# 上海交通大学工科试验班分流考回忆题（2024–2026）

本仓库收录上海交通大学工科试验班平台预分专业能力测试（“分流考”）
2024、2025、2026 三年的回忆题，统一使用
[exam-zh](https://gitee.com/xkwxdyy/exam-zh) 文档类排版。

> 回忆版试题，疏漏之处请见谅。工试群版权所有，仅供学习，严禁商用。

## 目录结构

```
.
├── Makefile                 # 一键构建
├── README.md
├── scripts/build.sh         # 构建脚本（供 Makefile 调用）
├── exam-zh/                 # 共享的 LaTeX 文档类（vendored，LPPL 1.3c）
├── dist/                    # 构建输出的 PDF
├── 2024/
│   ├── fenliukao.tex        # 2024 年排版源文件
│   ├── 数学.md              # 原始回忆素材
│   ├── 逻辑.md
│   ├── 致谢.md
│   ├── 题号分配方案.md
│   └── 分流问卷/            # 分流问卷统计材料
├── 2025/
│   ├── fenliukao.tex
│   ├── 数学.md
│   ├── 逻辑.md
│   └── 题号分配方案.md
└── 2026/
    ├── fenliukao.tex
    ├── 数学.md
    ├── 逻辑.md
    ├── 致谢.md
    ├── 题号分配方案.md
    └── figures/             # 2026 年数学第 26、28 题插图
```

## 构建

### 依赖

- **TeX Live 2023 或更高版本**，需包含 XeLaTeX、latexmk 与 `twemojis`；
- 中文字体：
  - Windows：宋体（SimSun）、黑体（SimHei）、华文宋体（STSong）等；
  - Linux：可使用 Fandol 字体，或安装与 Windows 对应的中文字体。

`exam-zh` v0.2.3 使用了较新的 LaTeX 内核 hook 机制，TeX Live 2020
等旧版本无法编译。可先用 `make check` 检查环境。

### 常用命令

```bash
make            # 构建 2024、2025、2026 三套试题
make 24         # 只构建 2024
make 25         # 只构建 2025
make 26         # 只构建 2026
make check      # 检查 latexmk / xelatex / exam-zh 是否就绪
make clean      # 删除 build/
make distclean  # 删除 build/ 和 dist/
```

构建时脚本会把仓库内的 `exam-zh`（v0.2.3）复制到构建目录，
并置于 `TEXINPUTS` 最前面，避免 TeX Live 2026 自带的 exam-zh
v0.3.6 覆盖仓库版本。输出文件为：

```
dist/24分流考回忆题.pdf   # 9 页
dist/25分流考回忆题.pdf   # 9 页
dist/26分流考回忆题.pdf   # 10 页
```


## 版权

- 试题内容：上海交通大学工科试验班相关群组版权所有，
  仅供学习交流，严禁商用。
- `exam-zh/`：LaTeX Project Public License v1.3c，
  详见 [exam-zh/LICENSE](exam-zh/LICENSE)。
