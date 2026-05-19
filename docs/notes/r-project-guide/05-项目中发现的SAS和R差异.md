# 05-项目中发现的SAS和R差异

> 记录在SHR-A1811-206项目中发现的SAS和R之间的行为差异及对应处理方式

---

## 1. NA排序问题 ✅ 已解决

**问题描述**

在SAS中，缺失值（`.`）在数值排序时默认排在最小值之前（即排第一位）；而R中，`NA`在排序时默认排在最后。这会导致使用`arrange()`排序后，数据行顺序与SAS不一致。

**示例**

```r
# R默认排序：NA排在最后
arrange(data, var)  # NA → 排在末尾

# SAS默认排序：缺失值排在最前
# proc sort data=...; by var; run;  → 缺失值排在最前
```

**解决方法**

已通过改写相关内置function - `fct_sort_addseq` / `fct_sort_add_seq`解决，在排序时对NA值做特殊处理，使其行为与SAS保持一致：

```r
# 方法：在arrange中用na_value将NA视为最小值
arrange(data, is.na(var), var)  # 先将NA提前，再按var排序
```

---

## 2. SAS数据中NA值与空字符串的区分 ⚠️ 需注意

**问题描述**

在SAS中，字符型变量的缺失值存储为空字符串`""`，与R中的`NA`是两个不同概念。使用`haven::read_sas()`读入SAS数据时，SAS的空字符串会被读入为R的`""`而非`NA`，在后续判断缺失值时若直接使用`is.na()`将无法捕获这些空字符串，需要加以注意。

**当前项目的处理方式**

项目环境中在批量读入和存储raw数据时，已统一调用`haven::convert_blanks_to_na()`对所有字符型空字符串进行处理，将其转换为`NA`，因此**在读取已处理过的rds/RData数据时无需额外处理**。

```r
# 项目中批量读入raw数据时已统一做如下处理
sas_data <- haven::read_sas("data.sas7bdat") %>%
  haven::convert_blanks_to_na()  # 将字符型""批量转为NA
```

**需要注意的场景**

若在后续程序中**独立使用`haven::read_sas()`直接读取SAS原始数据**（而非读取已处理的rds），则需手动处理空字符串，否则`is.na()`判断将遗漏原本在SAS中为缺失的记录：

```r
# ❌ 未处理时：SAS空字符串读入后为""，is.na()无法捕获
sas_data <- haven::read_sas("data.sas7bdat")
is.na(sas_data$var)   # SAS中的空字符串不会被判断为NA

# ✅ 推荐：读入后立即转换
sas_data <- haven::read_sas("data.sas7bdat") %>%
  haven::convert_blanks_to_na()
is.na(sas_data$var)   # 此时SAS空字符串已转为NA，判断生效
```

---

## 3. 数值转字符时小数位数精度不一致 ❌ 暂无完美解决方案

**问题描述**

在SAS中，常见做法是用`put(numeric_var, best12.)`将数值型变量转换为字符型（如生成`--STRESC`变量）。SAS的`best`格式会根据字段宽度自动选择最优表示方式，通常保留约8位有效数字；而R中使用`as.character()`转换时，会输出更多位数的小数，导致两边`STRESC`字符串不一致。

**示例**

以EG domain为例，`EGSTRESC`出现3203处差异，BASE（SAS）和COMPARE（R）的数值在数学上近似，但字符串表示不同：

| BASE（SAS `put(x, best12.)` ） | COMPARE（R `as.character()` ） |
|-------------------------------|-------------------------------|
| `426.45938446` | `426.459384457014` |
| `393.03071748` | `393.030717481388` |
| `396.8711879` | `396.871187903705` |

根本原因：SAS和R底层浮点数精度处理逻辑不同，且SAS `best`格式的截断规则较为复杂，难以在R中完全还原。

**目前建议方案**

### 方案一：比对时排除STRESC变量（推荐 ★★★）

若`--STRESC`仅由数值型结果直接转换而来，且`--STRESN`已通过数值比对，则`--STRESC`的字符差异属于已知精度问题，可在QC比对时将其排除。

```r
# 使用fct_qc时，通过exclude_vars参数排除
fct_qc(domain = Domain, output_txt = TRUE, show_result = TRUE,
       key_vars = c("STUDYID", "USUBJID", "SUBJID", "EGSEQ"),
       exclude_vars = "EGSTRESC",
       path = path)

# 直接使用diffdf时，通过setdiff排除指定变量
diffdf::diffdf(df1, df2, keys = c("USUBJID", "EGSEQ"),
               vars_to_compare = setdiff(names(df1), "EGSTRESC"))
```

### 方案二：手动指定精度转换（不推荐 ★）

可尝试用`sprintf()`或`formatC()`在R中模拟SAS的有效数字位数，但实际效果不稳定，无法保证与SAS完全一致：

```r
sprintf("%.8g", 396.871187903705)               # "%.8g" 表示8位有效数字
formatC(396.871187903705, digits = 8, format = "g")
```

不推荐使用`options(digits = 8)`，该设置为全局数值型小数print位数参数，不适用当前问题。

### 方案三：编写R函数模拟SAS put行为（不推荐 ★）

理论上可编写函数完全模拟`put(x, best12.)`的输出，但存在以下问题：

- SAS `best`格式在整数、小数、科学计数之间的切换边界条件复杂
- 不同平台、不同SAS版本的浮点精度行为可能存在细微差异
- 难以保证所有数值情况下对齐，维护成本高

```r
sas_best <- function(x, width = 12) {
  # 处理 NA
  if (is.na(x)) return(NA_character_)
  # 取绝对值，判断整数部分位数
  int_digits <- floor(log10(abs(x))) + 1
  if (int_digits <= 0) int_digits <- 1   # 小于1的情况
  # 小数部分允许的最大位数（总宽度 - 整数部分位数 - 小数点占1位）
  max_dec <- max(0, width - int_digits - 1)
  # 格式字符串，例如 "%.10f"
  fmt <- sprintf("%%.%df", max_dec)
  # 格式化并去掉尾部无意义的零和点（SAS best 不会输出末尾零）
  res <- sprintf(fmt, x)
  res <- gsub("\\.?0+$", "", res)
  return(res)
}

# 测试
sas_best(396.871187903705, 12)
# 输出 "396.8711879" （与 SAS 一致）
```

**结论**：优先使用**方案一**，在`STRESN`数值比对通过的前提下，跳过`STRESC`的字符串比对，记录为已知精度差异即可。
