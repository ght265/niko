"""Create a learning note without overwriting existing files."""
import argparse
from datetime import date
from pathlib import Path
import re


def main():
    parser = argparse.ArgumentParser(description="创建一条不覆盖已有文件的学习记录")
    parser.add_argument("--topic", required=True, help="例如 su-components")
    parser.add_argument("--date", type=date.fromisoformat, default=None, help="YYYY-MM-DD")
    args = parser.parse_args()
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", args.topic):
        parser.error("topic 仅接受小写英文字母、数字及单个连字符")

    root = Path(__file__).resolve().parents[1]
    template = root / "learning" / "TEMPLATE.md"
    day = (args.date or date.today()).isoformat()
    target = root / "learning" / f"{day}-{args.topic}.md"
    try:
        content = template.read_text(encoding="utf-8")
        content = content.replace("# 学习记录：待填写", f"# 学习记录：{args.topic}", 1)
        content = content.replace("- 日期：待填写", f"- 日期：{day}", 1)
        with target.open("x", encoding="utf-8", newline="\n") as output:
            output.write(content)
    except FileExistsError:
        parser.exit(1, f"未创建：文件已存在 {target.name}\n")
    except OSError as error:
        parser.exit(1, f"未创建：{error}\n")
    print(f"已创建：{target.relative_to(root)}")


if __name__ == "__main__":
    main()
