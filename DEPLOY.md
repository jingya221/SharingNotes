# 🚀 部署指南

本文档说明如何将 R Project 开发指南部署到 GitHub Pages。

## 📋 前置要求

- GitHub 账号
- Git 已安装
- Python 3.6+ 已安装

## 🔧 部署步骤

### 1. 配置 GitHub 仓库

仓库已创建：`https://github.com/jingya221/SharingNotes`

### 2. 推送代码到 GitHub

```bash
# 添加所有文件
git add .

# 提交更改
git commit -m "初始化: R Project 开发指南"

# 添加远程仓库（如果还没添加）
git remote add origin https://github.com/jingya221/SharingNotes.git

# 推送到 GitHub
git push -u origin main
```

### 3. 配置 GitHub Pages

#### 方式一：使用 GitHub Actions（推荐）

本项目已配置 GitHub Actions 自动部署（`.github/workflows/deploy.yml`）。

需要在 GitHub 仓库中配置：

1. 进入仓库的 **Settings** → **Pages**
2. **Source** 选择 **GitHub Actions**
3. 保存配置

之后每次推送到 `main` 分支，都会自动构建和部署。

#### 方式二：手动部署

如果不使用 GitHub Actions：

1. 本地构建站点：
   ```bash
   mkdocs build
   ```

2. 部署到 GitHub Pages：
   ```bash
   mkdocs gh-deploy
   ```

### 4. 验证部署

部署成功后，访问：
```
https://jingya221.github.io/SharingNotes/
```

通常需要 2-5 分钟生效。

## 🔄 更新流程

### 添加或修改指南

1. 编辑 `docs/notes/` 下的 Markdown 文件
2. 运行更新脚本：
   ```bash
   python update_readme.py
   ```
3. 提交并推送：
   ```bash
   git add .
   git commit -m "更新: 指南内容"
   git push
   ```

GitHub Actions 会自动构建和部署更新。

## 🛠️ 本地开发

### 安装依赖

```bash
pip install mkdocs mkdocs-material mkdocs-minify-plugin
```

### 本地预览

```bash
mkdocs serve
```

访问 `http://127.0.0.1:8000` 查看效果。

### 构建静态站点

```bash
mkdocs build
```

生成的站点在 `site/` 目录。

## 📊 GitHub Actions 工作流

项目配置了自动化部署工作流（`.github/workflows/deploy.yml`）：

- **触发条件**: 推送到 `main` 分支
- **构建过程**: 安装依赖 → 构建 MkDocs → 部署到 GitHub Pages
- **部署目标**: `gh-pages` 分支

查看部署状态：
- 仓库页面的 **Actions** 标签
- 提交记录旁的状态图标

## 🔍 故障排查

### 部署失败

1. 检查 GitHub Actions 日志
2. 确认 `mkdocs.yml` 配置正确
3. 验证所有链接和图片路径

### 页面不显示

1. 检查 GitHub Pages 设置
2. 确认 Actions 部署成功
3. 清除浏览器缓存

### 样式异常

1. 检查 Material 主题版本
2. 验证 `mkdocs.yml` 配置
3. 本地预览确认效果

## 📝 注意事项

1. **分支保护**: `main` 分支为主分支，`gh-pages` 由 Actions 自动管理
2. **构建时间**: 首次部署可能需要 5-10 分钟
3. **缓存**: 更新后如果看不到变化，尝试清除浏览器缓存
4. **图片路径**: 确保图片使用相对路径

## 🆘 需要帮助？

- 查看 [MkDocs 文档](https://www.mkdocs.org/)
- 查看 [Material 主题文档](https://squidfunk.github.io/mkdocs-material/)
- 提交 [GitHub Issue](https://github.com/jingya221/SharingNotes/issues)

---

*最后更新: 2026-02-28*
