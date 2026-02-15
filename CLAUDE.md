# Gcode

Lightweight coding agent built with Agno. Operates inside a Docker container with a persistent workspace volume.

## Architecture

- Agent definition: `gcode/agent.py`
- API server: `app/main.py` (FastAPI + AgentOS)
- Database: PostgreSQL + pgvector (for knowledge and learnings only, not user data)
- Workspace: `/workspace` volume (persistent, git-backed projects)

## Key Concepts

- CodingTools: file read/write/edit, shell, grep, find, ls
- ReasoningTools: `think` tool for complex reasoning chains
- LearningMachine: saves and retrieves project conventions, codebase quirks, user preferences
- Workspace: each project gets a folder, each task gets a git worktree

## Structure

```
gcode/
├── app/
│   ├── main.py          # AgentOS entry point
│   └── config.yaml      # Quick prompts config
├── gcode/
│   ├── __init__.py
│   ├── agent.py          # Gcode agent definition
│   └── workspace/        # Local dev workspace (gitignored)
├── db/
│   ├── __init__.py
│   ├── session.py        # PostgreSQL session factory + knowledge factory
│   └── url.py            # Database URL builder
├── scripts/
│   ├── venv_setup.sh
│   ├── format.sh
│   └── validate.sh
├── compose.yaml
├── Dockerfile
├── pyproject.toml
├── requirements.txt
├── example.env
├── GITHUB_ACCESS.md
├── CLAUDE.md
└── README.md
```

## Running

```bash
docker compose up -d --build
```

Connect via os.agno.com → Add OS → Local → http://localhost:8000

## Local Development

```bash
./scripts/venv_setup.sh && source .venv/bin/activate
docker compose up -d gcode-db
python -m gcode  # CLI mode
```

## Commands

```bash
./scripts/venv_setup.sh && source .venv/bin/activate
./scripts/format.sh      # Format code
./scripts/validate.sh    # Lint + type check
python -m gcode           # CLI mode
python -m gcode.agent     # Test mode (runs sample task)
```

## No data loading required

Gcode has no sample data or static knowledge to load.
The workspace starts empty and the agent creates projects as needed.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI API key |
| `GITHUB_TOKEN` | No | Fine-grained PAT for GitHub access |
| `DB_*` | No | Database config (defaults to localhost) |
