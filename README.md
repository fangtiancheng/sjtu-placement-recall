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

三份 PDF 均已随仓库提供；重新运行构建会覆盖 `dist/` 中的同名文件。
本项目已在 TeX Live 2026（Windows）上完整构建验证。

> **Windows 提示**：如果 `make --version` 显示的是 GNU Make 3.75
> （Windows 自带的旧版 make），请改用 MinGW 提供的
> `mingw32-make`，例如 `mingw32-make 26`。
>
> PowerShell 里的 `bash` 可能被解析为 WSL 的启动器（未安装 WSL 时会
> 报“适用于 Linux 的 Windows 子系统没有已安装的分发”）。Makefile
> 已改为自动调用 Git for Windows 自带的 `bash.exe`，前提是 Git 已安装
> 且 `git` 在 PATH 中；无需手动配置。
>
> 仓库路径含中文时，脚本会把中间文件放到系统临时目录（纯 ASCII
> 路径），构建成功后再删除。这是因为 TeX Live 2026 的 `xelatex`
> 无法把中文路径写入 `TEXMF_OUTPUT_DIRECTORY`。
>
> 如果终端是在安装 TeX Live 之前启动的，`PATH` 可能尚未刷新。构建
> 脚本会自动在常见位置（如 `G:\texlive\<年份>\bin\windows`）查找；
> 也可以用环境变量 `TEXLIVE_BIN` 显式指定 TeX Live 的 `bin` 目录。

### 常见构建错误

- `检测到 TeX Live 2020，exam-zh v0.2.3 需要 TeX Live 2023 或更高版本。`
- `\disable@package@load` / `\AddToHook` 未定义；
- `tabularray.sty not found`。

以上通常说明 TeX Live 版本过旧（如 TeX Live 2020），
请升级到 **TeX Live 2023 或更高版本**。

## 各年份说明

### 2024

除试题外，还保留了“题号分配方案”和“分流问卷”的统计材料，
供回忆题征集与数据参考。

### 2025

排版格式作为 2026 年整理时的模板：数学、逻辑各 30 题，
题号连续编号 1–60。

### 2026

- 数学部分 30 题、逻辑部分 30 题，题号连续编号 1–60。
- **第 52 题原始素材缺失**，当前在 PDF 中以占位说明保留题号，
  欢迎补充。
- 封面“制作人员”名单和 26 群群号来自回忆素材，欢迎继续校对。
- 数学第 26、28 题的插图文件来自原始素材中的 SJTU Notes 链接：
  - <https://notes.sjtu.edu.cn/uploads/0fdf0598-08e8-4f72-867a-359e63558b5a.png>
  - <https://notes.sjtu.edu.cn/uploads/779fcf3e-6265-4d4f-b77f-5e68b27c802a.png>
- 整理时修正了 Markdown 素材中的少量笔误（如全角等号、选项大小写、
  “百分位数”写法等），未改变题意。

## 编辑与贡献

- 正式的排版源文件是各年份目录下的 `fenliukao.tex`；
- `.md` 文件是回忆素材，便于检索和校对；
- 修改后运行 `make 26`（或对应年份）即可重新生成 PDF；
- 如果修改了 `exam-zh/` 中的文档类，请先阅读该目录下的
  [UPSTREAM.md](exam-zh/UPSTREAM.md)。

## 版权

- 试题内容：上海交通大学工科试验班相关群组版权所有，
  仅供学习交流，严禁商用。
- `exam-zh/`：LaTeX Project Public License v1.3c，
  详见 [exam-zh/LICENSE](exam-zh/LICENSE)。
