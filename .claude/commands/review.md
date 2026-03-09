Review the current branch as a senior software engineer. Be honest, opinionated, and educational.

1. Run `git diff main --stat` and `git diff main` to see all changes on this branch.
2. Run `git log --oneline main..HEAD` to see all commits.
3. Check `git status` for untracked or unstaged files that should be included.
4. Review against the Pre-PR Checklist from CLAUDE.md:
   - No secrets or credentials exposed (passwords, connection strings)
   - `.env.example` updated if `.env` changed
   - Init script syntax valid (bash + SQL)
   - docker-compose.yml syntax correct
   - Existing databases not affected by changes
   - Makefile targets work correctly
5. Categorize findings: must fix, should fix, nit/optional.
6. Give a clear verdict: ready to push, or list what needs fixing first.
