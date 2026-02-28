# 📘 R Project 开发指南

> 🌐 **在线浏览**: [https://jingya221.github.io/SharingNotes/](https://jingya221.github.io/SharingNotes/)

欢迎来到 R 语言项目开发指南！这里收录了 R 语言项目开发的最佳实践、工作流程和实用技巧。

# 📘 R Project 开发指南

欢迎来到 R 语言项目开发指南！这里收录了 R 语言项目开发的最佳实践、工作流程和实用技巧。

!!! tip "关于本指南"
    本指南基于真实的制药行业 R 项目经验总结，涵盖了从项目结构到编码规范的完整工作流程。适合参与 R 语言数据分析项目的程序员和分析师参考。

---

## 📚 指南内容

### 🗂️ r-project-guide

#### [01-R项目结构](docs/notes/r-project-guide/01-R项目结构.md)
> 案例来源SHR-1811-206项目，QC部分用R写代码，spec和codelist共用main...


#### [02-R程序指南](docs/notes/r-project-guide/02-R程序指南.md)

---

## 🎯 适用场景

本指南特别适合以下场景：

- ✅ 制药行业的 R 语言统计编程项目
- ✅ 需要规范化的团队协作 R 项目
- ✅ 使用 SDTM/ADaM 标准的临床试验数据分析
- ✅ 需要质量控制 (QC) 流程的 R 项目

---

## 🚀 快速开始

### 了解项目结构
从 R 项目结构指南开始，了解如何组织你的 R 项目文件和目录。

### 掌握关键工具
学习如何使用以下核心工具：

- `{renv}` - R 包依赖管理
- `{metacore}` - Spec 和 Codelist 管理
- `{metatools}` - 基于 Spec 的数据处理
- `batchrun` - 批量运行和日志管理

---

## 📖 参考资源

### 官方文档
- [renv 包文档](https://rstudio.github.io/renv/articles/renv.html) - R 环境管理工具
- [metatools 包文档](https://pharmaverse.github.io/metatools/) - Pharmaverse 元数据工具
- [metacore 包文档](https://atorus-research.github.io/metacore/) - 规范和代码列表管理

### 相关社区
- [Pharmaverse](https://pharmaverse.org/) - 制药行业 R 包生态系统
- [R for Clinical Study Reports](https://www.r4csr.org/) - 临床研究报告的 R 语言实践

---

## 💡 贡献与反馈

如果你有任何建议或发现问题，欢迎通过以下方式联系：

- 📧 提交 [GitHub Issue](https://github.com/jingya221/SharingNotes/issues)
- 🔗 访问 [GitHub 仓库](https://github.com/jingya221/SharingNotes)

---

## 📊 指南统计

- **指南分类**: 1 个
- **文档数量**: 2 篇
- **最近更新**: 2026-02-28

---

> 💡 **提示**: 使用左侧导航栏浏览所有指南内容，使用顶部搜索功能快速查找信息。

---

## 🎯 适用场景

本指南特别适合以下场景：

- ✅ 制药行业的 R 语言统计编程项目
- ✅ 需要规范化的团队协作 R 项目
- ✅ 使用 SDTM/ADaM 标准的临床试验数据分析
- ✅ 需要质量控制 (QC) 流程的 R 项目

---

## 🚀 快速开始

### 方式一：在线浏览（推荐）

访问 [GitHub Pages](https://jingya221.github.io/SharingNotes/) 获得最佳阅读体验，支持：

- 🔍 全文搜索功能
- 🌓 深色/浅色模式切换
- 📱 移动端自适应
- 🔗 便捷的链接分享

### 方式二：本地运行

```bash
# 1. 克隆仓库
git clone https://github.com/jingya221/SharingNotes.git
cd SharingNotes

# 2. 安装依赖
pip install mkdocs mkdocs-material mkdocs-minify-plugin

# 3. 本地预览
mkdocs serve

# 4. 访问 http://127.0.0.1:8000
```

---

## 📁 项目结构

```
SharingNotes/
├── docs/                    # MkDocs 文档目录
│   ├── index.md            # 首页
│   ├── notes/              # 指南文档
│   │   └── r-project-guide/  # R 项目指南
│   └── guide/              # 使用说明
├── mkdocs.yml              # MkDocs 配置文件
├── update_readme.py        # 自动更新脚本
├── update_notes.bat        # Windows 批处理文件
└── README.md               # 项目说明（本文件）
```

---

## 🤝 贡献指南

### 添加新指南

1. 在 `docs/notes/` 目录下创建新的分类文件夹或使用现有分类
2. 创建 Markdown 文件，确保包含一级标题
3. 如有图片，请放在同级目录下
4. 运行 `python update_readme.py` 自动更新索引

### 提交更改

```bash
git add .
git commit -m "添加: 新指南文档"
git push origin main
```

---

## 📄 许可证

本项目内容采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh) 许可协议。

---

*📅 最后更新: 2026-02-28 13:56:44*

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/jingya221">Jingya Wang</a>
</p>
