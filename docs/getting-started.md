---
title: 快速上手
nav_order: 2
---

# 快速上手

## 项目结构

```
dft-skills-market/
├── orca-dft-skills/          # ORCA 技能包
│   ├── main/SKILL.md         # 主分发器
│   ├── skills/               # 子技能（扁平结构）
│   ├── shared/               # 模板、脚本、参考资料
│   └── examples/             # 示例输入/输出
├── docs/                     # 文档站点（Just the Docs）
│   ├── index.md              # ORCA 概览
│   └── geometry-optimization.md
└── .github/workflows/        # GitHub Actions 部署
```

## 使用技能

每个技能包都是一个独立的文件夹。你可以：

1. **直接使用** — 将整个 `xxx-dft-skills/` 文件夹复制到你的工作目录
2. **独立安装** — 只需要哪个软件的技能，就复制哪个文件夹
3. **无交叉依赖** — 不同软件包之间没有任何关联

## 运行 ORCA 计算

生成 `.inp` 文件后，在终端中运行：

```bash
export ORCA_MAXCORE=4000    # 设置可用内存（MB）
orca <filename>.inp > <filename>.out
```

## 后续步骤

- 查看 **[ORCA 文档](../docs/orca/)** 学习几何优化输入生成
- 阅读 **[架构说明](../docs/architecture.md)** 了解 SKILL.md 格式
- 参考 **[贡献指南](../docs/contributing.md)** 添加新技能
