---
title: 几何优化输入生成
parent: ORCA
nav_order: 1
---

# 几何优化输入生成

## 功能说明

根据分子系统描述，生成完整的、可直接用于学术研究的 ORCA 5+ 几何优化 `.inp` 输入文件。

**单一职责**：仅处理几何优化输入生成，不处理频率计算、TDDFT、单点能等。

## 输入参数

| 参数 | 必填 | 默认值 | 说明 |
|---|---|---|---|
| `name` | 是 | - | 分子名称（用于注释/文件名） |
| `coordinates` | 是 | - | XYZ 格式坐标（元素 X Y Z，每行一个原子） |
| `charge` | 否 | 0 | 分子电荷（整数） |
| `multiplicity` | 否 | 1 | 自旋多重度（2S+1，整数 ≥ 1） |
| `functional` | 否 | B3LYP | DFT 泛函名称 |
| `basis` | 否 | def2-TZVP | 基组名称 |
| `molecule_type` | 否 | organic | `organic` / `transition-metal` / `charged` / `bulk` |
| `convergence` | 否 | tight | `normal` / `tight` / `verytight` |

## 泛函与基组推荐

| 系统 | 推荐泛函 | 推荐基组 | 说明 |
|---|---|---|---|
| 有机分子（闭壳层） | B3LYP、PBE0 | def2-TZVP | 出版级标准 |
| 大分子（快速预优化） | BP86 | def2-SVP | GGA + RIJ，速度快 |
| 过渡金属（第一行） | PBE0、TPSS | def2-TZVP | 严格 SCF 收敛 |
| 过渡金属（重金属） | PBE0 | def2-TZVP + ECP | 第二/三行需 ECP |
| 阴离子 | wB97X-D、B3LYP | def2-TZVPD | 弥散函数必需 |
| 阳离子 | B3LYP、PBE0 | def2-TZVP | 标准基组即可 |
| Minnesota 泛函 | M06-2X | def2-TZVP | 必须用 DefGrid3 |

## 生成的输入文件结构

```
# <泛函>-D3(BJ)/<基组> 级别的几何优化
# ORCA 5+ 输入文件 -- 用于学术研究

! <泛函> D3BJ <基组> Opt <收敛级别> <RI模式> <格点> TightSCF

%maxcore <内存_MB>

[可选 %scf 块 — 过渡金属或多重度 > 1 时添加]

[可选 %geom 块 — 按分子类型设置]

* xyz <电荷> <多重度>
<坐标>
*
```

## 关键字选择规则

### 色散校正
始终包含 `D3BJ`。

### 收敛级别
- `tight`（默认，出版推荐）→ `TightOpt`
- `verytight`（基准、光谱）→ `VeryTightOpt`
- `normal`（仅筛选）→ 无额外关键字（ORCA 默认 NormalOpt）

### RI 近似（自动选择）
- 杂化泛函（B3LYP、PBE0、wB97X-D、M06-2X）→ `RIJCOSX`
- 纯 GGA/meta-GGA（BP86、PBE、TPSS）→ `RIJ`

### 积分格点
- 默认 → `DefGrid2`
- Minnesota 泛函、重金属（第三行+）、阴离子 → `DefGrid3`

## %geom 块设置

**有机分子**（默认）：
```
%geom
  Calc_Hess true
  Recalc_Hess 5
end
```

**过渡金属**：
```
%geom
  Calc_Hess true
  Recalc_Hess 3
end
```

**大分子**：
```
%geom
  Calc_Hess true
  Recalc_Hess 10
end
```

## 示例：苯的几何优化

```
# 苯在 B3LYP-D3(BJ)/def2-TZVP 级别的几何优化
# ORCA 5+ 输入文件 -- 用于学术研究

! B3LYP D3BJ def2-TZVP Opt TightOpt RIJCOSX DefGrid2 TightSCF

%maxcore 4000

%geom
  Calc_Hess true
  Recalc_Hess 5
end

* xyz 0 1
 C    0.000000    1.402700    0.000000
 C    1.214700    0.701350    0.000000
 ...
*
```

运行命令：
```bash
orca benzene-opt.inp > benzene-opt.out
```

## 学术质量标准

所有生成的输入必须满足：

- 始终包含 D3BJ 色散校正
- SCF 收敛为 TightSCF 或更严格
- 几何收敛为 TightOpt 或更严格（NormalOpt 仅用于筛选）
- 基组匹配系统类型（出版用三重zeta，阴离子加弥散）
- 格点设置适合泛函和系统类型
- 电荷/多重度在使用前经过验证
- 完整的自包含输入文件（无外部依赖）

## 后续步骤

优化完成后，**务必**进行频率计算以确认稳定点为真正的极小值（无虚频）。
