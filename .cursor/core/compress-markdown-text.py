#!/usr/bin/env python3
"""Trim Markdown/plain text for token-compression.sh (stdin -> stdout)."""
import re
import sys


def compress(text: str) -> str:
    if not text:
        return ""
    emoji_pat = re.compile(
        "["
        "\U0001f300-\U0001faff\U00002600-\U000027bf\U0001f600-\U0001f64f"
        "\U0001f680-\U0001f6ff\U00002700-\U000027bf"
        "\u2600-\u26ff\u2705\u274c\u26a0\ufe0f"
        "]+"
    )
    out: list[str] = []
    prev_hr = False
    for line in text.splitlines():
        s = line.strip()
        if re.match(r"^\[!\[.*\]\(https?://", line):
            continue
        if s == "---":
            if prev_hr:
                continue
            prev_hr = True
            out.append(line)
            continue
        prev_hr = False
        line = emoji_pat.sub("", line)
        line = re.sub(r"[ \t]+$", "", line)
        out.append(line)
    t = "\n".join(out)
    t = re.sub(r"\n{3,}", "\n\n", t)
    t = re.sub(r"[ \t]{2,}", " ", t)
    t = re.sub(r"!{2,}", "!", t)
    t = re.sub(r"\?{2,}", "?", t)
    return t.strip() + ("\n" if t.strip() else "")


def main() -> None:
    raw = sys.stdin.read()
    sys.stdout.write(compress(raw))


if __name__ == "__main__":
    main()
