# Gcode

A lightweight coding agent that writes, reviews, and iterates on code. Gets sharper the more you use it.

Gcode operates inside a container with a persistent workspace volume. Each project is a git repo. Each task gets its own worktree. All code persists across container restarts.

## Quick Start

```sh
# Clone this repo
git clone https://github.com/agno-agi/gcode.git && cd gcode

# Add OPENAI_API_KEY
cp example.env .env
# Edit .env and add your key

# Start the application
docker compose up -d --build
```

No data loading required — the workspace starts empty and Gcode creates projects as you ask.

Confirm Gcode is running at [http://localhost:8000/docs](http://localhost:8000/docs).

## Connect to the Web UI

1. Open [os.agno.com](https://os.agno.com) and login
2. Add OS → Local → `http://localhost:8000`
3. Click "Connect"

**Try it:**

- Build a URL shortener with FastAPI and tests
- What projects exist in the workspace?
- Review the code in my most recent project
- Fix any failing tests in url-shortener

## How It Works

Gcode owns its workspace entirely — you interact through conversation, not an editor.

```
You: "Build a URL shortener with FastAPI"
     ↓
Gcode: mkdir /workspace/url-shortener && git init
     ↓
Creates worktree → writes code → runs tests → commits
     ↓
Reports what it built, what tests pass, and the git log
```

Each task gets its own git worktree — isolated branch, isolated files. Switch between tasks without losing state.

## Self-Learning

Gcode improves with use through two complementary systems:

| System | Stores | How It Evolves |
|--------|--------|----------------|
| **Knowledge** | Project metadata, conventions | Curated by you + Gcode |
| **Learnings** | Error patterns, codebase quirks, user preferences | Managed by Learning Machine automatically |

When Gcode discovers that a project uses `pytest` with fixtures in `conftest.py`, it saves that. Next time you ask about tests, it already knows.

## GitHub Access

Gcode can clone and push to GitHub repos using a fine-grained Personal Access Token.

See [GITHUB_ACCESS.md](GITHUB_ACCESS.md) for setup instructions.

## Architecture

```
gcode/
├── app/main.py        # FastAPI + AgentOS entry point
├── gcode/agent.py     # Agent definition (CodingTools + ReasoningTools + LearningMachine)
├── db/                # PostgreSQL session (for knowledge/learnings storage)
├── compose.yaml       # Docker services (api + postgres)
└── Dockerfile         # Non-root container with git, workspace volume
```

**Key components:**

- **CodingTools**: file read/write/edit, shell, grep, find, ls
- **ReasoningTools**: `think` tool for complex debugging chains
- **LearningMachine**: saves and retrieves project conventions, gotchas, user preferences
- **Workspace**: persistent Docker volume at `/workspace`

## Local Development

```sh
./scripts/venv_setup.sh && source .venv/bin/activate
docker compose up -d gcode-db
python -m gcode  # CLI mode
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI API key |
| `GITHUB_TOKEN` | No | Fine-grained PAT for cloning/pushing repos |
| `DB_*` | No | Database config (defaults to localhost) |

## Further Reading

- [Agno Docs](https://docs.agno.com)
- [Discord](https://agno.com/discord)
