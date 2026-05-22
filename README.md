# DFT Skills Market

面向密度泛函理论（DFT）计算的可移植 AI 技能市场。为 **ORCA 5+**、**VASP 6.x**、**Quantum ESPRESSO 7.x**、**Gaussian 16** 和 **CP2K 2024.x** 提供模块化、按需安装的技能套件，涵盖输入生成、错误诊断、输出解析和工作流自动化。

[![GitHub Pages](https://github.com/syllzp/dft-skills-market/actions/workflows/pages.yml/badge.svg)](https://github.com/syllzp/dft-skills-market/actions/workflows/pages.yml)

---

## 支持的软件包

| 软件 | 包目录 | 就绪子技能 | 状态 |
|------|--------|-----------|------|
| **ORCA** 5+ | `orca-dft-skills/` | `geo-opt-input`, `sp-energy-input`, `freq-input`, `tddft-input`, `basis-reference`, `relativistic-reference`, `multireference-reference`, `output-parse`, `error-diagnosis` | ✅ **全部就绪** |
| **VASP** 6.x | `vasp-dft-skills/` | `geo-opt-input`, `sp-energy-input`, `freq-input`, `output-parse`, `error-diagnosis` | ✅ **全部就绪** |
| **Quantum ESPRESSO** 7.x | `qe-dft-skills/` | `geo-opt-input`, `sp-energy-input`, `freq-input`, `output-parse`, `error-diagnosis` | ✅ **全部就绪** |
| **Gaussian** 16 | `gaussian-dft-skills/` | `geo-opt-input`, `sp-energy-input`, `freq-input`, `tddft-input`, `basis-reference`, `relativistic-reference`, `multireference-reference`, `output-parse`, `error-diagnosis` | ✅ **全部就绪** |
| **CP2K** 2024.x | `cp2k-dft-skills/` | `geo-opt-input`, `sp-energy-input`, `freq-input`, `output-parse`, `error-diagnosis` | ✅ **全部就绪** |

> ORCA 和 Gaussian 额外支持 **TDDFT/激发态计算输入生成**、**基组选择参考**、**相对论效应计算参考** 和 **多参考计算（CASSCF/CASCI）** 子技能。

---

## 特性

- **完全独立** — 每个软件技能包 100% 可移植，可独立拷贝使用
- **单一职责** — 每个子技能专注一项功能：输入生成 / 错误诊断 / 输出解析
- **最佳实践** — 遵循各 DFT 软件官方推荐设置和参数
- **学术就绪** — 生成的输入文件可直接用于学术论文和研究
- **HPC 就绪** — 每个软件包均包含 SLURM 作业提交模板
- **验证脚本** — 内置输入验证脚本，避免常见错误

---

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/syllzp/dft-skills-market.git

# 只需拷贝需要的软件包
cp -r dft-skills-market/orca-dft-skills/ /my/project/
```

详细指南见 [快速上手](./getting-started.md)。

---

## 项目结构

```
dft-skills-market/
├── orca-dft-skills/            # ORCA 技能包
├── vasp-dft-skills/            # VASP 技能包
├── qe-dft-skills/              # Quantum ESPRESSO 技能包
├── gaussian-dft-skills/        # Gaussian 技能包
├── cp2k-dft-skills/            # CP2K 技能包
├── .github/workflows/          # GitHub Pages 自动部署
├── index.md                    # 站点首页
├── architecture.md             # 架构说明
├── getting-started.md          # 快速上手
├── contributing.md             # 贡献指南
└── _config.yml                 # Jekyll 配置
```

每个技能包遵循一致的内部结构：

```
xxx-dft-skills/
├── main/SKILL.md               # 分发器：列出子技能、分配任务
├── skills/
│   ├── geo-opt-input/SKILL.md  # 几何优化输入生成（单一职责）
│   ├── sp-energy-input/SKILL.md # 单点能输入生成（单一职责）
    │   ├── freq-input/SKILL.md     # 频率计算输入生成（单一职责）
    │   ├── output-parse/SKILL.md   # 输出文件解析（单一职责）
    │   ├── error-diagnosis/SKILL.md # 异常诊断（单一职责）
    │   └── basis-reference/SKILL.md # 基组选择参考（ORCA/Gaussian 专属）
├── shared/
│   ├── templates/              # 输入模板
│   ├── references/             # 快速参考文档
│   └── scripts/                # 辅助验证脚本
└── examples/                   # 示例输入/输出
```

---

## 文档站点

本项目使用 **Jekyll** + **just-the-docs** 主题构建文档站点并通过 GitHub Pages 部署。

### 本地预览

```bash
bundle install
bundle exec jekyll serve
```

### 自动部署

推送至 `main` 分支后，GitHub Actions 自动构建并部署到 GitHub Pages。

---

## 开发指南

参考 [贡献指南](./contributing.md) 了解如何：

- 添加新的 DFT 软件包
- 编写 SKILL.md 分发器
- 创建子技能
- 添加模板、脚本和示例

---

## 许可证

[MIT](./LICENSE) © 2026 SYL
