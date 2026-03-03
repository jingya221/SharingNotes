# SAS 与 R 数据处理代码对比

## 1. 数据处理

### 1.1 基础操作

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 基础操作</strong>
    <pre><code class="language-sas">
/* 创建新变量 */
data new_data;
  set mydata;
  new_var = old_var * 2;
  new_var2 = ifc(new_var > 10, "大", "小");
run;

/* 条件筛选 */
data filtered;
  set mydata;
  if var1 > 100 and var2 = 'A' then output;
run;

/* 条件赋值 */
data recoded;
  set mydata;
  length status $10;
  if score >= 90 then status = 'Excellent';
  else if score >= 80 then status = 'Good';
  else if score >= 60 then status = 'Pass';
  else status = 'Fail';
run;

/* 选择/删除变量 */
data subset;
  set mydata;
  keep var1 var2 new_var;
  drop var3 var4;
run;

/* 排序 */
proc sort data=mydata;
  by descending var1 var2;
run;
    </code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R (dplyr) 基础操作</strong>
    <pre><code class="language-r">
library(dplyr)

# 创建新变量和条件筛选
new_data <- mydata %>%
  mutate(
    new_var = old_var * 2,  # 创建新变量
    new_var2 = ifelse(new_var > 10, "大", "小"),  # 条件赋值
    status = case_when(  # 多条件赋值
      score >= 90 ~ "Excellent",
      score >= 80 ~ "Good",
      score >= 60 ~ "Pass",
      TRUE ~ "Fail"
    )
  ) %>%
  filter(var1 > 100, var2 == "A") %>%  # 条件筛选
  select(var1, var2, new_var) %>%  # 选择变量
  select(-var3, -var4) %>%  # 删除变量
  arrange(desc(var1), var2)  # 排序
    </code></pre>
  </div>
</div>

### 1.2 数据类型：缺失值，重复值，字符数值转换

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 数据类型处理</strong>
    <pre><code class="language-sas">
/* 处理缺失值 */
data handle_missing;
  set mydata;
  
  /* 检查缺失值 */
  if missing(var1) then var1_missing = 1;
  else var1_missing = 0;
  
  /* 替换缺失值 */
  if missing(var2) then var2 = 0;
  
  /* 使用均值填充 */
  if missing(var3) then var3 = mean(of var3);
run;

/* 处理重复值 */
/* 删除完全重复的行 */
proc sort data=mydata nodupkey;
  by _all_;
run;

/* 删除基于关键变量的重复行 */
proc sort data=mydata nodupkey;
  by id_var;
run;

/* 标记重复值 */
proc sort data=mydata;
  by id_var date_var;
run;

data dup_marked;
  set mydata;
  by id_var;
  if first.id_var and last.id_var then dup_flag = 0;
  else dup_flag = 1;
run;

/* 数据类型转换 */
data type_convert;
  set mydata;
  
  /* 字符转数值 */
  num_var = input(char_var, best12.);
  
  /* 数值转字符 */
  char_var2 = put(num_var, best12.);
run;
    </code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R 数据类型处理</strong>
    <pre><code class="language-r">
library(dplyr)
library(tidyr)

# 处理缺失值
clean_data <- mydata %>%
  mutate(
    # 检查缺失值
    var1_missing = is.na(var1),
    
    # 替换缺失值
    var2 = ifelse(is.na(var2), 0, var2),
    
    # 使用均值填充
    var3 = ifelse(is.na(var3), mean(var3, na.rm = TRUE), var3)
  )

# 使用tidyr的填充函数
clean_data <- mydata %>%
  fill(var1, .direction = "down") %>%  # 向下填充
  replace_na(list(var3 = 0, var4 = "Unknown"))

# 处理重复值
# 删除完全重复的行
deduped <- mydata %>%
  distinct()  # 或 distinct(.keep_all = TRUE)

# 删除基于关键变量的重复行
deduped_by_id <- mydata %>%
  distinct(id_var, .keep_all = TRUE)

# 标记重复值
marked_dups <- mydata %>%
  group_by(id_var) %>%
  mutate(
    dup_flag = ifelse(n() > 1, 1, 0),
    dup_count = n()
  ) %>%
  ungroup()

# 数据类型转换
converted <- mydata %>%
  mutate(
    # 字符转数值
    num_var = as.numeric(char_var),
    
    # 数值转字符
    char_var2 = as.character(num_var),
    
    # 因子转换
    factor_var = as.factor(category_var)
  )
    </code></pre>
  </div>
</div>

## 2. 分组汇总

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 分组汇总</strong>
    <pre><code class="language-sas">
/* 基本汇总统计 */
proc means data=mydata;
  var numeric_var1 numeric_var2;
  class category_var;
  output out=summary
    mean=avg1 avg2
    std=std1 std2
    n=n1 n2;
run;

/* 分组汇总 */
proc summary data=mydata nway;
  class group_var;
  var value_var;
  output out=group_summary
    mean=avg_value
    sum=total_value
    n=count;
run;

/* 分组汇总（SQL方式） */
proc sql;
  create table group_summary as
  select 
    group_var,
    count(*) as count,
    mean(value_var) as avg_value,
    sum(value_var) as total_value,
    std(value_var) as std_value
  from mydata
  group by group_var;
quit;

/* 分组排序 */
proc sort data=mydata;
  by group_var descending value_var;
run;

data ranked;
  set mydata;
  by group_var;
  retain rank;
  if first.group_var then rank = 0;
  rank + 1;
run;
    </code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R (dplyr) 分组汇总</strong>
    <pre><code class="language-r">
library(dplyr)

# 基本汇总
mydata %>%
  summarise(
    avg_var1 = mean(var1, na.rm = TRUE),
    sd_var1 = sd(var1, na.rm = TRUE),
    count = n(),
    .groups = "drop"
  )

# 分组汇总
group_summary <- mydata %>%
  group_by(group_var) %>%
  summarise(
    count = n(),
    avg_value = mean(value_var, na.rm = TRUE),
    total_value = sum(value_var, na.rm = TRUE),
    sd_value = sd(value_var, na.rm = TRUE),
    .groups = "drop"
  )

# 多个分组变量
multi_group <- mydata %>%
  group_by(group1, group2) %>%
  summarise(
    avg = mean(value, na.rm = TRUE),
    .groups = "drop"
  )

# 分组排序
ranked <- mydata %>%
  group_by(group_var) %>%
  arrange(desc(value_var), .by_group = TRUE) %>%
  mutate(rank = row_number())

# 窗口函数
mydata %>%
  group_by(group_var) %>%
  mutate(
    lag_value = lag(value_var),      # 前一行
    lead_value = lead(value_var),    # 后一行
    cumsum_value = cumsum(value_var) # 累计和
  ) %>%
  ungroup()
    </code></pre>
  </div>
</div>

## 3. 数据连接与转置

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 数据连接与转置</strong>
<pre><code class="language-sas">
/* 横向合并（内连接） */
data merged;
  merge data1(in=a) data2(in=b);
  by key_var;
  if a and b;  /* 内连接 */
run;

/* 左连接 */
data left_join;
  merge data1(in=a) data2(in=b);
  by key_var;
  if a;  /* 左连接 */
run;

/* 纵向合并 */
data appended;
  set data1 data2 data3;
run;

/* 数据转置（宽转长） */
proc transpose data=wide
  out=long
  name=variable
  value=value;
  by id_var;
  var var1 var2 var3;
run;

/* 数据转置（长转宽） */
proc transpose data=long
  out=wide
  delimiter=_;
  by id_var;
  id variable;
  var value;
run;
</code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R 数据连接与转置</strong>
<pre><code class="language-r">
library(dplyr)
library(tidyr)

# 横向合并
# 内连接
merged <- inner_join(data1, data2, by = "key_var")

# 左连接
left_joined <- left_join(data1, data2, by = "key_var")

# 右连接
right_joined <- right_join(data1, data2, by = "key_var")

# 全连接
full_joined <- full_join(data1, data2, by = "key_var")

# 纵向合并
appended <- bind_rows(data1, data2, data3)

# 数据转置（宽转长）
long <- wide %>%
  pivot_longer(
    cols = c(var1, var2, var3),
    names_to = "variable",
    values_to = "value"
  )

# 数据转置（长转宽）
wide_data <- long %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )

# 交叉连接
cross_joined <- crossing(data1, data2)

# 半连接（保留左表中在右表存在的行）
semi_joined <- semi_join(data1, data2, by = "key_var")

# 反连接（保留左表中不在右表的行）
anti_joined <- anti_join(data1, data2, by = "key_var")
</code></pre>
  </div>
</div>

## 4. 字符串处理

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 字符串处理</strong>
<pre><code class="language-sas">
/* 字符串长度 */
data string_ops;
  set mydata;
  len = length(string_var);  /* 字符长度 */
run;

/* 提取子字符串 */
data substr_example;
  set mydata;
  first_3 = substr(string_var, 1, 3);  /* 提取前3个字符 */
run;

/* 查找与替换 */
data find_replace;
  set mydata;
  /* 查找位置 */
  pos = index(string_var, "search_text");
  
  /* 替换 */
  new_str = tranwrd(string_var, "old", "new");
run;

/* 大小写转换 */
data case_convert;
  set mydata;
  upper_str = upcase(string_var);  /* 转大写 */
  lower_str = lowcase(string_var);  /* 转小写 */
  proper_str = propcase(string_var);  /* 首字母大写 */
run;

/* 去除空格 */
data trim_example;
  set mydata;
  left_trim = left(string_var);  /* 去除左侧空格 */
  right_trim = right(string_var);  /* 去除右侧空格 */
  both_trim = strip(string_var);  /* 去除两侧空格 */
run;

/* 字符串连接 */
data concat;
  set mydata;
  /* 连接字符串 */
  full_name = cat(first_name, " ", last_name);
  full_name2 = catx(" ", first_name, last_name);  /* 自动处理分隔符 */
run;

/* 字符串分割 */
data split;
  set mydata;
  /* 分割字符串 */
  length part1 part2 part3 $50;
  part1 = scan(string_var, 1, ",");
  part2 = scan(string_var, 2, ",");
  part3 = scan(string_var, 3, ",");
run;
</code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R (stringr) 字符串处理</strong>
<pre><code class="language-r">
library(stringr)
library(dplyr)
library(tidyr)

# 字符串长度
mydata %>%
  mutate(len = str_length(string_var))

# 提取子字符串
mydata %>%
  mutate(
    first_3 = str_sub(string_var, 1, 3),  # 提取前3个字符
    last_3 = str_sub(string_var, -3)     # 提取最后3个字符
  )

# 查找与替换
mydata %>%
  mutate(
    # 查找位置
    pos = str_locate(string_var, "search_text")[, "start"],
    
    # 替换（所有出现）
    new_str = str_replace_all(string_var, "old", "new"),
    
    # 替换（第一次出现）
    new_str_first = str_replace(string_var, "old", "new")
  )

# 大小写转换
mydata %>%
  mutate(
    upper_str = str_to_upper(string_var),    # 转大写
    lower_str = str_to_lower(string_var),    # 转小写
    title_str = str_to_title(string_var)     # 标题格式
  )

# 去除空格
mydata %>%
  mutate(
    trim_both = str_trim(string_var),        # 去除两侧空格
    trim_left = str_trim(string_var, "left"),  # 去除左侧空格
    trim_right = str_trim(string_var, "right") # 去除右侧空格
  )

# 字符串连接
mydata %>%
  mutate(
    full_name = str_c(first_name, " ", last_name)
  )

# 字符串分割
# 分割为多列
mydata %>%
  separate(
    string_var, 
    into = c("part1", "part2", "part3"), 
    sep = ",", 
    extra = "merge",  # 处理多余部分
    fill = "right"    # 处理不足部分
  )

# 模式匹配
mydata %>%
  mutate(
    # 检测是否包含模式
    has_pattern = str_detect(string_var, "pattern"),
    
    # 提取匹配内容
    extracted = str_extract(string_var, "[0-9]+")
  )
</code></pre>
  </div>
</div>

## 5. 日期处理

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 日期处理</strong>
<pre><code class="language-sas">
/* 日期创建与转换 */
data date_ops;
  /* 创建日期 */
  date1 = '17JAN2023'd;  /* 日期常量 */
  date2 = mdy(1, 17, 2023);  /* 月日年函数 */
  date3 = today();  /* 当前日期 */
  
  /* 字符转日期 */
  char_date = '2023-01-17';
  date4 = input(char_date, yymmdd10.);
  
  /* 日期转字符 */
  char_date2 = put(date1, yymmdd10.);
  char_date3 = put(date1, date9.);
  
  /* 时间创建 */
  time1 = '14:30:00't;
  time2 = hms(14, 30, 0);
  
  /* 日期时间 */
  datetime1 = '17JAN2023:14:30:00'dt;
  datetime2 = dhms(date1, 14, 30, 0);
run;

/* 日期提取 */
data date_extract;
  set mydata;
  year = year(date_var);
  month = month(date_var);
  day = day(date_var);
  quarter = qtr(date_var);
  weekday = weekday(date_var);  /* 1=周日, 2=周一, ... */
run;

/* 日期计算 */
data date_calc;
  set mydata;
  /* 加减天数 */
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
</code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R (lubridate) 日期处理</strong>
<pre><code class="language-r">
library(lubridate)
library(dplyr)

# 日期创建与解析
mydata <- mydata %>%
  mutate(
    # 从各种格式解析日期
    date1 = ymd("2023-01-17"),  # 年-月-日
    date2 = dmy("17/01/2023"),  # 日/月/年
    date3 = mdy("01/17/2023"),  # 月/日/年
    
    # 从组件创建日期
    date4 = make_date(year = 2023, month = 1, day = 17),
    
    # 当前日期
    today_date = today(),
    
    # 日期时间
    datetime1 = ymd_hms("2023-01-17 14:30:00")
  )

# 日期提取
mydata <- mydata %>%
  mutate(
    year = year(date_var),
    month = month(date_var, label = TRUE),  # 加label返回月份名
    day = day(date_var),
    yday = yday(date_var),  # 一年中的第几天
    week = week(date_var),  # 一年中的第几周
    weekday = wday(date_var, label = TRUE)  # 星期几
  )

# 日期计算
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
    days_diff = as.numeric(date2 - date1),
    weeks_diff = interval(date1, date2) / weeks(1)
  )

# 日期格式化和解析
mydata <- mydata %>%
  mutate(
    # 格式化为字符串
    date_str = format(date_var, "%Y-%m-%d"),
    datetime_str = format(datetime_var, "%Y-%m-%d %H:%M:%S")
  )
</code></pre>
  </div>
</div>

## 6. 其他

<div style="display: flex; justify-content: space-between; gap: 20px;">
  <div style="width: 48%;">
    <strong>SAS 其他常用操作</strong>
<pre><code class="language-sas">
/* 创建虚拟变量/指示变量 */
data dummy;
  set mydata;
  
  /* 手动创建 */
  if category = 'A' then cat_A = 1; else cat_A = 0;
  if category = 'B' then cat_B = 1; else cat_B = 0;
  if category = 'C' then cat_C = 1; else cat_C = 0;
run;

/* 使用数组批量处理 */
data array_example;
  set mydata;
  array vars{3} var1-var3;
  array new_vars{3} new1-new3;
  
  do i = 1 to 3;
    new_vars{i} = vars{i} * 2;
  end;
  drop i;
run;

/* 创建数据透视表 */
proc tabulate data=mydata;
  class category_var;
  var numeric_var;
  table category_var, numeric_var*(mean sum n);
run;

/* 输出描述性统计 */
proc contents data=mydata;
run;

proc means data=mydata n mean std min max;
  var numeric_var1 numeric_var2;
run;

/* 创建格式 */
proc format;
  value scorefmt
    low-59 = 'Fail'
    60-79 = 'Pass'
    80-89 = 'Good'
    90-high = 'Excellent';
run;

data formatted;
  set mydata;
  format score scorefmt.;
run;
</code></pre>
  </div>
  <div style="width: 48%;">
    <strong>R 其他常用操作</strong>
<pre><code class="language-r">
library(dplyr)
library(tidyr)

# 创建虚拟变量/指示变量
dummy_data <- mydata %>%
  mutate(
    cat_A = ifelse(category == "A", 1, 0),
    cat_B = ifelse(category == "B", 1, 0),
    cat_C = ifelse(category == "C", 1, 0)
  )

# 使用model.matrix创建虚拟变量
dummy_matrix <- model.matrix(~ category - 1, data = mydata)

# 重编码变量
recoded <- mydata %>%
  mutate(
    # 使用case_when进行条件重编码
    status = case_when(
      score >= 90 ~ "Excellent",
      score >= 80 ~ "Good",
      score >= 60 ~ "Pass",
      TRUE ~ "Fail"
    ),
    
    # 使用recode直接重编码
    grade_group = dplyr::recode(grade,
      "A" = "High",
      "B" = "High",
      "C" = "Medium",
      "D" = "Low",
      "F" = "Low",
      .default = "Unknown"
    ),
    
    # 使用cut进行分箱
    score_bin = cut(score,
      breaks = c(0, 60, 80, 90, 100),
      labels = c("Fail", "Pass", "Good", "Excellent"),
      include.lowest = TRUE
    )
  )

# 数据重塑
# 宽表转长表
long_data <- mydata %>%
  pivot_longer(
    cols = starts_with("value_"),
    names_to = "time_period",
    values_to = "measurement"
  )

# 长表转宽表
wide_data <- long_data %>%
  pivot_wider(
    names_from = time_period,
    values_from = measurement
  )

# 描述性统计
# 基本统计
summary(mydata)

# 使用dplyr的汇总
mydata %>%
  summarise(
    n = n(),
    mean_var1 = mean(var1, na.rm = TRUE),
    sd_var1 = sd(var1, na.rm = TRUE),
    median_var1 = median(var1, na.rm = TRUE),
    min_var1 = min(var1, na.rm = TRUE),
    max_var1 = max(var1, na.rm = TRUE)
  )

# 频率表
table(mydata$category_var)
prop.table(table(mydata$category_var))
</code></pre>
  </div>
</div>