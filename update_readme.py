#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MkDocs笔记自动索引生成器
自动扫描docs/notes目录下的markdown文件，生成首页索引和导航配置
"""

import os
import re
import sys
import yaml
from datetime import datetime
from pathlib import Path
from collections import defaultdict, OrderedDict

# 修复 Windows 控制台编码问题
if sys.platform.startswith('win'):
    sys.stdout.reconfigure(encoding='utf-8') if hasattr(sys.stdout, 'reconfigure') else None

def extract_title_from_markdown(file_path):
    """从markdown文件中提取标题"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            
        # 查找第一个# 标题
        title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
        if title_match:
            return title_match.group(1).strip()
        
        # 如果没有找到标题，使用文件名
        return Path(file_path).stem
    except Exception as e:
        print(f"读取文件 {file_path} 时出错: {e}")
        return Path(file_path).stem

def extract_description_from_markdown(file_path):
    """从markdown文件中提取描述（第一段文字）"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # 去掉标题后的第一段非空文字
        lines = content.split('\n')
        description = ""
        found_title = False
        
        for line in lines:
            line = line.strip()
            if line.startswith('#'):
                found_title = True
                continue
            if found_title and line and not line.startswith('#') and not line.startswith('```') and not line.startswith('!!!'):
                # 取前50个字符作为描述，避免代码块
                description = line[:50] + ("..." if len(line) > 50 else "")
                break
        
        return description
    except Exception as e:
        return ""

def get_file_info(file_path):
    """获取文件信息"""
    stat = os.stat(file_path)
    modified_time = datetime.fromtimestamp(stat.st_mtime)
    
    # 获取相对于docs/notes文件夹的路径来确定分类
    relative_path = Path(file_path).relative_to(Path('./docs/notes'))
    
    # 改进分类逻辑：使用直接父文件夹作为分类
    if relative_path.parent == Path('.'):
        category = "根目录"
    else:
        # 使用直接父文件夹名作为分类
        category = relative_path.parent.name
    
    return {
        'path': file_path,
        'title': extract_title_from_markdown(file_path),
        'description': extract_description_from_markdown(file_path),
        'category': category,
        'modified': modified_time,
        'size': stat.st_size,
        'relative_path': str(relative_path),
        'folder_path': str(relative_path.parent) if relative_path.parent != Path('.') else ""
    }

def scan_notes_folder():
    """扫描docs/notes文件夹中的所有markdown文件"""
    notes_folder = Path('./docs/notes')
    if not notes_folder.exists():
        return []
    
    markdown_files = []
    for file_path in notes_folder.glob('**/*.md'):
        if file_path.is_file():
            file_info = get_file_info(file_path)
            markdown_files.append(file_info)
    
    # 按修改时间排序（最新的在前）
    markdown_files.sort(key=lambda x: x['modified'], reverse=True)
    return markdown_files

def generate_statistics(markdown_files):
    """生成统计信息"""
    if not markdown_files:
        return ""
    
    total_files = len(markdown_files)
    categories = set(file_info['category'] for file_info in markdown_files)
    total_categories = len(categories)
    
    # 最近更新统计
    today = datetime.now().date()
    recent_count = sum(1 for f in markdown_files if (today - f['modified'].date()).days <= 7)
    
    stats = [
        f"📝 **总笔记数：{total_files} 个**  ",
        f"📁 **分类数：{total_categories} 个**  ",
        f"🔥 **最近7天更新：{recent_count} 个**  ",
        f"📅 **最后更新：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}**",
        ""
    ]
    
    return '\n'.join(stats)

def generate_recent_updates(markdown_files):
    """生成最近更新列表"""
    if not markdown_files:
        return ""
    
    content = []
    today = datetime.now().date()
    recent_files = [f for f in markdown_files if (today - f['modified'].date()).days <= 7]
    
    if recent_files:
        for file_info in recent_files[:5]:  # 只显示最近5个
            # MkDocs相对路径
            page_path = file_info['relative_path'].replace('\\', '/').replace('.md', '')
            modified_str = file_info['modified'].strftime('%Y-%m-%d')
            category_badge = f"`{file_info['category']}`" if file_info['category'] != "根目录" else ""
            description = f" - {file_info['description']}" if file_info['description'] else ""
            content.append(f"- [**{file_info['title']}**](notes/{page_path}) {category_badge} *({modified_str})*{description}")
    
    return '\n'.join(content)

def update_mkdocs_nav(markdown_files):
    """更新mkdocs.yml中的导航配置"""
    mkdocs_file = Path('./mkdocs.yml')
    if not mkdocs_file.exists():
        print("mkdocs.yml文件不存在！")
        return False
    
    with open(mkdocs_file, 'r', encoding='utf-8') as file:
        config = yaml.safe_load(file)
    
    # 按分类组织文件，使用OrderedDict保持顺序
    categories = OrderedDict()
    for file_info in markdown_files:
        category = file_info['category']
        if category not in categories:
            categories[category] = []
        categories[category].append(file_info)
    
    # 生成导航结构 - 改进版本
    nav_notes = []
    
    # 对分类按名称排序，但根目录排在最前面
    sorted_categories = sorted(categories.keys(), key=lambda x: (x != "根目录", x))
    
    for category in sorted_categories:
        files = categories[category]
        if category == "根目录":
            # 根目录文件直接放在笔记分类下
            for file_info in sorted(files, key=lambda x: x['title']):
                page_path = file_info['relative_path'].replace('\\', '/')
                nav_notes.append({file_info['title']: f"notes/{page_path}"})
        else:
            # 其他分类作为子菜单
            category_nav = []
            for file_info in sorted(files, key=lambda x: x['title']):
                page_path = file_info['relative_path'].replace('\\', '/')
                category_nav.append({file_info['title']: f"notes/{page_path}"})
            nav_notes.append({category: category_nav})
    
    # 创建完整的导航结构
    new_nav = [
        {'首页': 'index.md'},
        {'笔记分类': nav_notes}
    ]
    
    # 直接替换整个导航配置
    config['nav'] = new_nav
    
    # 写回文件
    with open(mkdocs_file, 'w', encoding='utf-8') as file:
        yaml.dump(config, file, default_flow_style=False, allow_unicode=True, sort_keys=False)
    
    return True

def update_index_page(markdown_files):
    """更新docs/index.md首页"""
    index_file = Path('./docs/index.md')
    if not index_file.exists():
        print("docs/index.md文件不存在！")
        return False
    
    # 按分类组织文件
    categories = defaultdict(list)
    for file_info in markdown_files:
        categories[file_info['category']].append(file_info)
    
    # 生成笔记目录内容
    notes_content = []
    # 对分类按名称排序，但根目录排在最前面
    sorted_categories = sorted(categories.keys(), key=lambda x: (x != "根目录", x))
    
    for category in sorted_categories:
        notes_content.append(f"### 🗂️ {category}")
        files = categories[category]
        if files:
            for file_info in sorted(files, key=lambda x: x['title']):
                page_path = file_info['relative_path'].replace('\\', '/').replace('.md', '')
                description = f"\n{file_info['description']}" if file_info['description'] else ""
                notes_content.append(f"\n#### [{file_info['title']}](notes/{page_path}){description}\n")
        else:
            notes_content.append("*该分类暂无笔记*")
        notes_content.append("")
    
    # 生成统计信息
    total_files = len(markdown_files)
    total_categories = len(categories)
    latest_note = markdown_files[0]['title'] if markdown_files else "无"
    update_date = datetime.now().strftime('%Y-%m-%d')
    
    # 构建新的首页内容
    new_content = f"""# 临床R语言编程

---

## 📚 指南内容

{chr(10).join(notes_content).rstrip()}

---

## 📊 统计信息

- **指南分类**: {total_categories} 个
- **文档数量**: {total_files} 篇
- **最近更新**: {update_date}

---

<p align="center">
  <small>© 2026 Jingya Wang | <a href="https://github.com/jingya221/SharingNotes">GitHub</a></small>
</p>"""
    
    # 写入文件
    with open(index_file, 'w', encoding='utf-8') as file:
        file.write(new_content)
    
    return True

def update_readme_from_index():
    """根据docs/index.md的内容更新README.md"""
    index_file = Path('./docs/index.md')
    readme_file = Path('./README.md')
    
    if not index_file.exists():
        print("docs/index.md文件不存在！")
        return False
    
    try:
        # 读取index.md内容
        with open(index_file, 'r', encoding='utf-8') as file:
            index_content = file.read()
        
        # 调整链接路径：因为README.md在根目录，需要添加docs/前缀
        readme_content = index_content
        
        # 修复相对路径链接
        # 将 (guide/ 替换为 (docs/guide/
        readme_content = re.sub(r'\(guide/', r'(docs/guide/', readme_content)
        # 将 (notes/ 替换为 (docs/notes/
        readme_content = re.sub(r'\(notes/', r'(docs/notes/', readme_content)
        # README 导览使用 .md 文件链接（如 docs/notes/AI相关/R-shiny-with-AI.md）
        readme_content = re.sub(
            r'\((docs/notes/[^)]+)\)',
            lambda m: '(' + m.group(1) + ('' if m.group(1).endswith('.md') else '.md') + ')',
            readme_content
        )
        
        # 添加README.md特有的说明
        readme_header = """# 临床R语言编程

> 🌐 **在线浏览**: [https://jingya221.github.io/SharingNotes/](https://jingya221.github.io/SharingNotes/)

临床研究中R语言编程的指南和最佳实践。

---

"""
        
        readme_footer = f"""

---

## 🚀 快速开始

### 在线浏览（推荐）
访问 [https://jingya221.github.io/SharingNotes/](https://jingya221.github.io/SharingNotes/)

### 本地运行
```bash
# 克隆仓库
git clone https://github.com/jingya221/SharingNotes.git
cd SharingNotes

# 安装依赖
pip install mkdocs mkdocs-material mkdocs-minify-plugin

# 本地预览
mkdocs serve
```

---

## 📁 项目结构

```
SharingNotes/
├── docs/
│   ├── index.md
│   └── notes/
│       └── r-project-guide/
├── mkdocs.yml
├── update_readme.py
└── README.md
```

---

*📅 最后更新: {datetime.now().strftime('%Y-%m-%d')}*

<p align="center">
  © 2026 Jingya Wang | <a href="https://github.com/jingya221/SharingNotes">GitHub</a>
</p>
"""
        
        # 替换首页标题和说明
        readme_content = re.sub(r'^# .*?\n\n', '', readme_content, flags=re.MULTILINE | re.DOTALL)
        
        # 组合最终内容
        final_content = readme_header + readme_content + readme_footer
        
        # 写入README.md
        with open(readme_file, 'w', encoding='utf-8') as file:
            file.write(final_content)
        
        return True
    
    except Exception as e:
        print(f"更新README.md时出错: {e}")
        return False

def main():
    """主函数"""
    print("🔍 正在扫描docs/notes目录...")
    
    # 扫描笔记文件
    markdown_files = scan_notes_folder()
    
    if not markdown_files:
        print("❌ 未找到任何markdown文件！")
        return
    
    print(f"📝 找到 {len(markdown_files)} 个笔记文件")
    
    # 更新首页
    if update_index_page(markdown_files):
        print("✅ 已更新首页 (docs/index.md)")
    else:
        print("❌ 更新首页失败")
    
    # 更新导航配置
    if update_mkdocs_nav(markdown_files):
        print("✅ 已更新导航配置 (mkdocs.yml)")
    else:
        print("❌ 更新导航配置失败")
    
    # 更新README.md
    if update_readme_from_index():
        print("✅ 已更新README.md（基于index.md）")
    else:
        print("❌ 更新README.md失败")
    
    print("\n📊 统计信息:")
    categories = set(f['category'] for f in markdown_files)
    for category in sorted(categories):
        count = len([f for f in markdown_files if f['category'] == category])
        print(f"  {category}: {count} 个文件")
    
    print(f"\n🎉 更新完成！请运行 'mkdocs serve' 预览效果")

if __name__ == "__main__":
    main() 