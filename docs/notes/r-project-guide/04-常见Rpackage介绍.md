# 04-常见Rpackage介绍

> 主要介绍SHR-A1811-206项目中推荐使用到的package及相关function

## spec相关：metacore, metatools

### {metacore}设置并读取spec和codelist
> {metacore}：https://atorus-research.github.io/metacore/

### {metatools}调用spec

> {metatools}：https://pharmaverse.github.io/metatools/

本项目中，{metatools}中大部分相关内容已打包至相关function中，详细参考[03-内置funcion介绍](https://jingya221.github.io/SharingNotes/notes/r-project-guide/03-%E5%86%85%E7%BD%AEfuncion%E4%BB%8B%E7%BB%8D/)。

以下是一些常见的function，比如sort_by_key()，可以直接通过读取spec的ds_vars的排序变量顺序，对当前数据进行排序，避免在代码中手动赋值。

```R
add_labels() ## Apply labels to multiple variables on a data frame
add_variables() ## Add Missing Variables
build_from_derived() ## Build a dataset from derived
build_qnam() ## Build the observations for a single QNAM
check_ct_col() ## Check Control Terminology for a Single Column
check_ct_data() ## Check Control Terminology for a Dataset
check_unique_keys() ## Check Uniqueness of Records by Key
check_variables() ## Check Variable Names
combine_supp() ## Combine the Domain and Supplemental Qualifier
convert_var_to_fct() ## Convert Variable to Factor with Levels Set by Control Terms
create_cat_var() ## Create Categorical Variable from Codelist
create_subgrps() ## Create Subgroups
create_var_from_codelist() ## Create Variable from Codelist
drop_unspec_vars() ## Drop Unspecified Variables
get_bad_ct() ## Gets vector of control terminology which should be there
make_supp_qual() ## Make Supplemental Qualifier
metatools_example() ## Get path to pkg example
order_cols() ## Sort Columns by Order
remove_labels() ## Remove labels to multiple variables on a data frame
set_variable_labels() ## Apply labels to a data frame using a metacore object
sort_by_key() ## Sort Rows by Key Sequence
```

## 数据处理：dplyr, tidyr, stringr, lubridate

> {dplyr}:https://dplyr.tidyverse.org/ <br>
> {tidyr}:https://tidyr.tidyverse.org/ <br>
> {stringr}:https://stringr.tidyverse.org/ <br>
> {lubridate}:https://lubridate.tidyverse.org/ <br>

### 1. 数据处理

#### 1.1 基础操作

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
data new_data;
set mydata;
new_var = old_var * 2;
new_var2 = ifc(new_var > 10, "大", "小");

if var1 > 100 and var2 = 'A' then output;
/* 使用if-then-else */
length status $10;
if score >= 90 then status = 'Excellent';
else if score >= 80 then status = 'Good';
else if score >= 60 then status = 'Pass';
else status = 'Fail';

keep var1 var2 new_var;
drop var3 var4;
run;

proc sort data=mydata;
by descending var1 var2;
run;
```
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```r
new_data <- mydata %>%
  mutate(new_var = old_var * 2, # 创建新变量
         new_var2 = ifelse(new_var > 10, "大", "小"), # ifc和ifn在R中可统一用ifelse
         status = case_when( # 多个条件判断可用case_when
            score >= 90 ~ "Excellent",
            score >= 80 ~ "Good",
            score >= 60 ~ "Pass",
            TRUE ~ "Fail"
            )
         ) %>%  
  filter(var1 > 100, var2 == "A") %>%  # 条件筛选
  select(var1, var2, new_var) %>%  # 选择/保留变量
  select(-var3, -var4) %>%  # 删除变量
  arrange(desc(var1), var2)  # 降序排列用desc()
```
  </div>
</div>

#### 1.2 数据类型：缺失值，重复值，字符数值转换

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
/* 缺失值判断 */
missing(var)

/* 处理重复值 */
/* 删除完全重复的行 */
proc sort data=mydata nodupkey;
by all;
run;

/* 删除基于关键变量的重复行 */
proc sort data=mydata nodupkey;
by id_var;
run;

/* 数据类型转换 */
data type_convert;
set mydata;
num_var = input(char_var, best12.);
char_var2 = put(num_var, best12.);
run;
```
    </code></pre>
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```r
## 缺失值判断 
is.na(var) # 注意na是数据为空，但有些情况中字符型数据为""时，不属于NA，判断时需特别注意

## 处理重复值
deduped <- mydata %>%
    distinct() # 删除完全重复的行

deduped_by_id <- mydata %>%
    distinct(id_var) # 删除基于关键变量的重复行，当提供具体变量时，数据集中仅保留指定变量，类似于select(xxx) %>% distinct()

unique(mydata$vars) # 查看变量中不重复值

## 数值转换
converted <- mydata %>%
  mutate(
    num_var = as.numeric(char_var), # 字符转数值
    char_var2 = as.character(num_var), # 数值转字符
    factor_var = as.factor(category_var) # 因子转换
  )
```
  </div>
</div>

### 2. 分组汇总 - group_by & summarise

```R
group_summary <- mydata %>%
  group_by(group_var) %>%
  summarise(
    n = n(),
    mean_var1 = mean(var1, na.rm = TRUE),
    sd_var1 = sd(var1, na.rm = TRUE),
    median_var1 = median(var1, na.rm = TRUE),
    min_var1 = min(var1, na.rm = TRUE),
    max_var1 = max(var1, na.rm = TRUE)
  ) %>%
  ungroup() ## 在使用完group_by后一定要注意使用ungroup，避免影响后续其他计算

mydata %>%
  group_by(group_var) %>%
  mutate(
    lag_value = lag(value_var),      # 前一行
    lead_value = lead(value_var)    # 后一行
  ) %>%
  ungroup()
```

### 3. 数据连接与转置
```R
## 横向合并
merged <- inner_join(data1, data2, by = "key_var")
left_joined <- left_join(data1, data2, by = "key_var")
right_joined <- right_join(data1, data2, by = "key_var")
full_joined <- full_join(data1, data2, by = "key_var")

## 纵向合并，类似set操作
appended <- bind_rows(data1, data2, data3)

## 数据转置（用到tidyr包）
long <- wide %>%
  tidyr::pivot_longer(
    cols = c(var1, var2, var3),
    names_to = "variable",
    values_to = "value"
  )

wide_data <- long %>%
  tidyr::pivot_wider(
    names_from = variable,
    values_from = value
  )
```

### 4. 字符串处理 - stringr包

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
data string_ops;
  set mydata;
  len = length(string_var);  /* 字符长度 */
  first_3 = substr(string_var, 1, 3);  /* 提取前3个字符 */
  pos = index(string_var, "search_text"); /* 查找位置 */
  new_str = tranwrd(string_var, "old", "new"); /* 替换 */
  new_str2 = scan(string_var, 1, ","); /* 提取逗号前内容 */

  upper_str = upcase(string_var);  /* 转大写 */
  lower_str = lowcase(string_var);  /* 转小写 */
  proper_str = propcase(string_var);  /* 首字母大写 */

  left_trim = left(string_var);  /* 去除左侧空格 */
  right_trim = right(string_var);  /* 去除右侧空格 */
  both_trim = strip(string_var);  /* 去除两侧空格 */

  full_name = cat(first_name, " ", last_name);  /* 连接字符串 */
  full_name2 = catx(" ", first_name, last_name);  /* 自动处理分隔符 */

  /* 分割字符串 */
  length part1 part2 part3 $50;
  part1 = scan(string_var, 1, ",");
  part2 = scan(string_var, 2, ",");
  part3 = scan(string_var, 3, ",");
run;
```
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```R
mydata %>%
  mutate(len = str_length(string_var)，# 字符串长度
         
         first_3 = str_sub(string_var, 1, 3),  # 提取前3个字符
         last_3 = str_sub(string_var, -3)     # 提取最后3个字符
         
         pos = str_locate(string_var, "search_text")[, "start"], # 查找位置
         has_pattern = str_detect(string_var, "pattern"), # 检测是否包含模式
         extracted = str_extract(string_var, "[0-9]+"), # 提取匹配内容
         new_str = str_split_i(string_var, ",", i = 1), # 提取逗号前内容
         
         new_str = str_replace_all(string_var, "old", "new"), # 替换（所有出现）
         new_str_first = str_replace(string_var, "old", "new"), # 替换（只针对第一次出现）
         
         upper_str = str_to_upper(string_var),    # 转大写
         lower_str = str_to_lower(string_var),    # 转小写
         title_str = str_to_title(string_var),     # 标题格式
         
         trim_both = str_trim(string_var),        # 去除两侧空格
         trim_left = str_trim(string_var, "left"),  # 去除左侧空格
         trim_right = str_trim(string_var, "right"), # 去除右侧空格
         
         full_name = str_c(first_name, " ", last_name), # 连接字符串
         full_name = paste0(first_name, " ", last_name) # 连接字符串
         
  ) %>% 
  tidyr::separate( # 分割为多列（用到tidyr包）
    string_var,
    into = c("part1", "part2", "part3"),
    sep = ",",
    extra = "merge",  # 处理多余部分
    fill = "right"    # 处理不足部分
  )
```
  </div>
</div>


### 5. 日期处理

#### 5.1 日期转换
<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
data date_ops;
/* 字符转日期 */
date1 = input(char_date, yymmdd10.);
/* 日期转字符 */
char_date1 = put(date1, yymmdd10.);
run;
```
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```R
mydata <- mydata %>%
  mutate(
    date1 = ymd("2023-01-17"),  # 字符转日期
    date_str = format(date_var, "%Y-%m-%d"),  # 日期转字符
    datetime_str = format(datetime_var, "%Y-%m-%dT%H:%M") # 日期时间转字符
  )
```
  </div>
</div>

#### 5.2 日期提取
<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
data date_extract;
  set mydata;
  year = year(date_var);
  month = month(date_var);
  day = day(date_var);
  quarter = qtr(date_var);
  weekday = weekday(date_var);  / 1=周日, 2=周一, ... */
run;
```
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```R
mydata <- mydata %>%
  mutate(
    year = year(date_var),
    month = month(date_var, label = TRUE),  # 加label返回月份名
    day = day(date_var),
    yday = yday(date_var),  # 一年中的第几天
    week = week(date_var),  # 一年中的第几周
    weekday = wday(date_var, label = TRUE)  # 星期几
  )
```
  </div>
</div>


#### 5.3 日期计算
<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 38%;">
    <strong>SAS</strong>

```sas
data date_calc;
  set mydata;
  / 加减天数 */
  next_day = date_var + 1;
  prev_day = date_var - 1;

  /* 加减月份 */
  next_month = intnx('month', date_var, 1);
  prev_month = intnx('month', date_var, -1);

  /* 日期差 */
  days_diff = date2 - date1;
  months_diff = intck('month', date1, date2);
  years_diff = intck('year', date1, date2);
run;
```
  </div>
  <div style="width: 58%;">
    <strong>R</strong>

```R
mydata <- mydata %>%
  mutate(
    # 加减时间
    next_day = date_var + days(1),
    prev_day = date_var - days(1),
    next_week = date_var + weeks(1),
    next_month = date_var + months(1),
    next_year = date_var + years(1),
    
    # 到月末/月初
    month_start = floor_date(date_var, "month"),
    month_end = ceiling_date(date_var, "month") - days(1),
    
    # 日期差
    days_diff = as.numeric(date2 - date1), ## 这里的date2和date1需为Date格式，而非字符型
    weeks_diff = interval(date1, date2) / weeks(1)
  )
```
  </div>
</div>


## 数据读入和输出

### 1. 读入SAS数据：haven包
> {haven}:https://haven.tidyverse.org/

```R
sas_data <- haven::read_sas("/path/to/data.sas7bdat") 
```

### 2. 输出SAS数据：xportr包
> {xportr}:https://atorus-research.github.io/xportr/

```R
xportr::write_xportr(sas_data, "/path/to/output.xpt")
```

### 3. EXCEL数据
> {readxl}:https://readxl.tidyverse.org/
> {openxlsx}:https://ycphs.github.io/openxlsx/
> 注意：readxl包只能读入数据，无法写出数据，如果需要写出数据到excel文件，可以使用openxlsx包

```R
mydata <- readxl::read_excel("/path/to/input.xlsx", sheet = "Sheet1",  # 指定工作表
                     col_names = TRUE,
                     na = c("", "NA"))

mydata <- readxl::read_excel("/path/to/input.xlsx", col_types = "text") # 直接将所有列读入为字符型，避免readxl自动判断数据类型导致的错误
mydata <- readxl::read_excel("/path/to/input.xlsx", guess_max = Inf) # 增加guess_max参数，默认值为1000，增加后可以让readxl查看更多行数据来判断数据类型，避免前面几行数据类型单一导致的错误判断

mydata <- metacore::read_all_sheets("/path/to/input.xlsx") # 批量读入，内部调用的也是read_excel(., col_types = "text")

mydata <- openxlsx::read.xlsx("/path/to/input.xlsx", sheet = "Sheet1", 
                              colNames = TRUE, na.strings = c("", "NA")) # openxlsx的读入方法，功能和readxl类似，速度更快

openxlsx::write.xlsx(mydata, "/path/to/output.xlsx")
```

### 4. CSV数据
> {readr}:https://readr.tidyverse.org/
```R
mydata <- read.csv("/path/to/input.csv", header = TRUE, na.strings = c("", "NA")) # base R的读入方法
mydata <- readr::read_csv("/path/to/input.csv", col_names = TRUE, na = c("", "NA")) # readr包的读入方法

write.csv(mydata, "/path/to/output.csv", row.names = FALSE, na = "") # base R的写出方法，na=""可以将R中的NA写出为空字符串，避免在csv中出现NA字符
readr::write_csv(mydata, "/path/to/output.csv", na = "") # readr包的写出方法，功能和write.csv类似，速度更快
```

### 5. r数据格式

```R
# 保存单个对象
saveRDS(mydata, file = "/path/to/output.rds") # 保存为rds格式
mydata <- readRDS("/path/to/output.rds") # 读取rds格式

# 保存多个对象
save(mydata, file = "/path/to/output.RData") # 保存为RData格式
load("/path/to/output.RData") # 读取RData格式
```

## 数据对比：diffdf
> {diffdf}:https://gowerc.github.io/diffdf/latest-tag/

```R
diffdf::diffdf(df1, df2)

## 显示数据集中比对差异
diff <- diffdf::diffdf(df1, df2, suppress_warnings = TRUE)
diffdf::diffdf_issuerows(df1, diff)
diffdf::diffdf_issuerows(df2, diff)
```

## 一些其他用法


### 1. 循环

```R
# FOR循环
for(i in 1:10) {
  squared <- i^2
  print(paste(i, "squared is", squared))
}

# WHILE循环
i <- 1
while(i <= 10) {
  squared <- i^2
  print(paste(i, "squared is", squared))
  i <- i + 1
}
```

### 2. 条件执行
```R
# if语句
x <- 10
if(x > 5) {
  print("x is greater than 5")
} else if(x == 5) {
  print("x is equal to 5")
} else {
  print("x is less than 5")
}

# switch语句
day <- "Monday"
result <- switch(day,
                 "Monday" = "Start of the week",
                 "Friday" = "End of the week",
                 "Weekend")
print(result)
```

## 进阶推荐 

### apply, lapply, sapply等函数，适合对数据框的每一列或每一行进行操作，替代使用for循环

### purrr: map系列函数，适合对列表或数据框的每一行进行操作，替代使用for循环
https://purrr.tidyverse.org/

### admiral: CDISC数据处理包，包含很多针对CDISC数据处理的function
https://pharmaverse.github.io/admiral/cran-release/index.html

### TLG catalog：包含大多数的图表制作方法和代码，后续出具TFL时可以参考
https://insightsengineering.github.io/tlg-catalog/stable/
