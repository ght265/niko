# 小脚本

## 创建学习记录

需要 Python 3.9 或以上，无第三方依赖。从仓库根目录运行：

```bash
python scripts/new_note.py --topic facade-materials
python scripts/new_note.py --topic ai-render-test --date 2026-10-19
```

Windows 可将 `python` 改为 `py -3`。若没有 Python，可直接复制学习模板，无需为了记录而安装环境。

- 不指定日期时使用电脑本地日期。
- 主题仅接受小写英文字母、数字及单个连字符，如 `su-components`。
- 输出为 `learning/YYYY-MM-DD-topic.md`。
- 从 `learning/TEMPLATE.md` 读取模板并填入标题与日期。
- 同名文件已存在时停止；脚本不联网、不改模型、不删除文件。
