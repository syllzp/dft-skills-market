---
title: ORCA
nav_order: 4
has_children: true
---

# ORCA 5+ 技能文档

ORCA 5+ 计算化学技能套件，遵循 ORCA 5+ 最佳实践，生成可直接用于学术研究的输入文件。

## 可用子技能

| 子技能 | 功能 | 路径 |
|---|---|---|
| geo-opt-input | 几何优化输入文件生成 | `orca-dft-skills/skills/geo-opt-input/` |

## 运行 ORCA

生成输入文件后，在终端运行：

```bash
export ORCA_MAXCORE=4000    # 可用内存（MB），按需调整
orca <input>.inp > <input>.out
```

## 最佳实践

所有生成的输入文件均遵循 ORCA 5+ 推荐：

- **色散校正**：始终包含 D3BJ（Grimme D3 + Becke-Johnson 阻尼）
- **SCF 收敛**：TightSCF 或更严格（确保梯度干净）
- **基组**：def2-TZVP（出版级质量），def2-TZVPD（阴离子需弥散函数）
- **RI 近似**：杂化泛函用 RIJCOSX，GGA 用 RIJ
- **积分格点**：DefGrid2（默认），Minnesota 泛函/重金属/阴离子用 DefGrid3
