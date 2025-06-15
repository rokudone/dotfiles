npm i -g @anthropic-ai/claude-code

curl -LsSf https://astral.sh/uv/install.sh | sh

# コードインデックス
ghq get https://github.com/johnhuang316/code-index-mcp.git
cd ~/projects/github.com/johnhuang316/code-index-mcp
uv sync
