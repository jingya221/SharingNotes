# 添加新指南

本页面介绍如何为本站添加新的指南文档。

## 📝 准备工作

### 环境要求

- Git（用于版本控制）
- 文本编辑器（推荐 VS Code、RStudio 等）
- Python 3.6+（用于运行更新脚本）
- MkDocs Material（可选，用于本地预览）

### 安装依赖

```bash
# 安装 MkDocs 和主题
pip install mkdocs mkdocs-material mkdocs-minify-plugin

# 安装 YAML 处理库
pip install pyyaml
```

---

## 📄 创建新指南

### 步骤 1：选择分类

确定你的指南属于哪个分类：

- **现有分类**: 在 `docs/notes/` 下已有的文件夹中添加
- **新分类**: 在 `docs/notes/` 下创建新文件夹

```bash
# 示例：创建新分类
cd docs/notes
mkdir new-category-name
```

!!! tip "文件夹命名建议"
    - 使用英文小写字母和连字符
    - 避免使用中文和特殊字符
    - 示例：`r-project-guide`、`data-analysis`、`shiny-development`

### 步骤 2：创建 Markdown 文件

在分类文件夹中创建 `.md` 文件：

```bash
cd docs/notes/your-category
touch 01-your-guide-name.md
```

!!! tip "文件命名建议"
    - 使用序号前缀便于排序：`01-`、`02-` 等
    - 使用描述性的英文名称
    - 示例：`01-project-structure.md`、`02-coding-standards.md`

### 步骤 3：编写内容

使用 Markdown 格式编写指南内容。必须包含一级标题：

```markdown
# 指南标题

> 可选：添加简短的引言或说明

## 第一章节

章节内容...

### 子章节

子章节内容...

## 第二章节

更多内容...
```

#### Markdown 语法建议

**基础格式**:
```markdown
# 一级标题
## 二级标题
### 三级标题

**粗体文字**
*斜体文字*
`行内代码`
```

**代码块**:
````markdown
```r
# R 代码示例
library(dplyr)
data %>% filter(age > 18)
```

```python
# Python 代码示例
import pandas as pd
df.head()
```
````

**列表**:
```markdown
- 无序列表项 1
- 无序列表项 2
  - 嵌套列表项

1. 有序列表项 1
2. 有序列表项 2
```

**链接和图片**:
```markdown
[链接文字](https://example.com)
![图片说明](image.png)
```

**提示框** (Material 主题扩展):
```markdown
!!! note "提示"
    这是一个提示框

!!! warning "警告"
    这是一个警告框

!!! tip "小贴士"
    这是一个小贴士
```

---

## 🖼️ 添加图片

### 图片存放位置

将图片放在与 Markdown 文件相同的目录下：

```
docs/notes/r-project-guide/
├── 01-R项目结构.md
├── image-1.png
├── image-2.png
└── ...
```

### 在文档中引用图片

```markdown
![图片描述](image-1.png)
```

!!! tip "图片命名建议"
    - 使用描述性名称：`project-structure.png`
    - 或使用序号：`image-1.png`、`image-2.png`
    - 避免使用中文文件名

---

## 🔄 更新索引

添加新指南后，需要更新站点索引和导航。

### 自动更新（推荐）

运行更新脚本自动生成索引：

```bash
# Windows
python update_readme.py

# 或使用批处理文件
update_notes.bat
```

脚本会自动：
- 扫描 `docs/notes/` 下的所有 Markdown 文件
- 更新 `docs/index.md` 首页
- 更新 `mkdocs.yml` 导航配置
- 更新 `README.md` 文件

### 手动更新

如果需要手动配置，编辑 `mkdocs.yml` 文件：

```yaml
nav:
- 首页: index.md
- R Project 项目指南:
  - R 项目结构: notes/r-project-guide/01-R项目结构.md
  - 你的新指南: notes/your-category/your-guide.md  # 添加这一行
- 使用指南:
  - 如何使用本站: guide/usage.md
  - 添加新指南: guide/add-notes.md
  - 更新索引: guide/update-index.md
```

---

## 👁️ 本地预览

在提交之前，建议本地预览效果：

```bash
# 启动本地服务器
mkdocs serve

# 浏览器访问
http://127.0.0.1:8000
```

本地服务器支持热重载，修改文件后会自动刷新页面。

---

## 📤 提交更改

### 步骤 1：添加文件到 Git

```bash
# 查看更改
git status

# 添加新文件
git add docs/notes/your-category/
git add docs/index.md
git add mkdocs.yml
git add README.md
```

### 步骤 2：提交更改

```bash
git commit -m "添加: 新指南 - 指南名称"
```

!!! tip "提交信息建议"
    - 使用清晰的描述性信息
    - 前缀示例：`添加:`、`更新:`、`修复:`
    - 示例：`添加: R 数据处理指南`

### 步骤 3：推送到 GitHub

```bash
git push origin main
```

### 步骤 4：等待部署

GitHub Pages 会自动构建和部署，通常需要 2-5 分钟。部署完成后访问：

```
https://jingya221.github.io/SharingNotes/
```

---

## ✅ 质量检查清单

提交新指南前，请确认：

- [ ] 文件包含一级标题（`# 标题`）
- [ ] 内容结构清晰，有合适的章节划分
- [ ] 代码块使用了正确的语法高亮
- [ ] 图片已添加并能正确显示
- [ ] 链接都是有效的
- [ ] 已运行更新脚本更新索引
- [ ] 本地预览效果良好
- [ ] 提交信息清晰描述了更改内容

---

## 🤝 贡献建议

### 内容质量

- ✅ 基于实际项目经验
- ✅ 提供可运行的代码示例
- ✅ 包含必要的说明和注释
- ✅ 适当使用图片辅助说明

### 文档风格

- ✅ 使用清晰简洁的语言
- ✅ 保持一致的格式风格
- ✅ 合理使用提示框和高亮
- ✅ 提供实用的参考链接

---

## 🆘 需要帮助？

如果在添加指南时遇到问题：

1. 查看现有指南作为参考
2. 阅读 [MkDocs Material 文档](https://squidfunk.github.io/mkdocs-material/)
3. 访问 [GitHub Issues](https://github.com/jingya221/SharingNotes/issues) 寻求帮助

---

感谢你为本项目做出贡献！🎉
