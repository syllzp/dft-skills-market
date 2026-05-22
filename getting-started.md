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
│   │   ├── geo-opt-input/    #   几何优化输入生成
│   │   ├── sp-energy-input/  #   单点能输入生成
│   │   ├── freq-input/       #   频率计算输入生成
│   │   ├── tddft-input/      #   TDDFT 激发态输入生成
│   │   ├── basis-reference/  #   基组选择参考
│   │   ├── relativistic-reference/  #   相对论效应参考
│   │   ├── output-parse/     #   输出文件解析
│   │   └── error-diagnosis/  #   异常诊断
│   ├── shared/               # 模板、脚本、参考资料
│   └── examples/             # 示例输入/输出
├── vasp-dft-skills/          # VASP 技能包
├── qe-dft-skills/            # Quantum Espresso 技能包
├── gaussian-dft-skills/      # Gaussian 技能包
├── cp2k-dft-skills/          # CP2K 技能包
└── .github/workflows/        # GitHub Pages 部署
```

## 使用技能

每个技能包都是一个独立的文件夹。你可以：

1. **直接使用** — 将整个 `xxx-dft-skills/` 文件夹复制到你的工作目录
2. **独立安装** — 只需要哪个软件的技能，就复制哪个文件夹
3. **无交叉依赖** — 不同软件包之间没有任何关联

## 运行 DFT 计算

### ORCA
```bash
export ORCA_MAXCORE=4000
orca <filename>.inp > <filename>.out
```

### VASP
```bash
mpirun -np <nproc> vasp_std
```

### Quantum Espresso
```bash
pw.x < <input>.in > <input>.out
```

### Gaussian
```bash
g16 < <filename>.com > <filename>.log
```

### CP2K
```bash
mpirun -np <nproc> cp2k.popt < <input>.inp > <input>.out
```

## 后续步骤

- 查看 **[架构说明](./architecture.md)** 了解 SKILL.md 格式
- 选择需要的软件包（`xxx-dft-skills/`）复制到工作目录
- 参考 **[贡献指南](./contributing.md)** 添加新技能
