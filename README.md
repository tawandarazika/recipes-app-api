# recipes-app-api

API for all your Top Recipes.

## Overview

This project uses Docker for local development and day-to-day Django commands.
Instead of typing long Docker commands, run the shortcuts in [make.ps1](make.ps1).

From the project root, the recommended form is:

```powershell
.\make.ps1 <target>
```

You can also use the shorter PowerShell form:

```powershell
.\make <target>
```

Both call into the same Docker-based workflow.

## Common Commands

### Docker lifecycle

```powershell
.\make.ps1 up
.\make.ps1 up --build
.\make.ps1 up -d
.\make.ps1 down
.\make.ps1 stop
.\make.ps1 restart
.\make.ps1 ps
.\make.ps1 logs -f app
.\make.ps1 build
.\make.ps1 rebuild
.\make.ps1 bash
```

### Django commands

```powershell
.\make.ps1 runserver
.\make.ps1 shell
.\make.ps1 dbshell
.\make.ps1 test
.\make.ps1 makemigrations
.\make.ps1 migrate
.\make.ps1 showmigrations
.\make.ps1 squashmigrations <app_label> <migration_name>
.\make.ps1 check
.\make.ps1 collectstatic
.\make.ps1 dumpdata
.\make.ps1 loaddata fixtures/data.json
.\make.ps1 createsuperuser
.\make.ps1 changepassword admin
.\make.ps1 startapp core
.\make.ps1 startproject app
.\make.ps1 cleanm core
.\make.ps1 manage shell
```

### Cleanup commands

```powershell
.\make.ps1 prune
.\make.ps1 prune-force
.\make.ps1 prune-global
.\make.ps1 prune-global-force
.\make.ps1 stop-all
.\make.ps1 rm-all
.\make.ps1 rmi-all
.\make.ps1 rm-volumes
.\make.ps1 nuke
.\make.ps1 pycache
```

## What The Cleanup Commands Do

- `prune` cleans only the current compose project.
- `prune-force` does the same project-scoped cleanup with a fast shutdown.
- `prune-global` and `prune-global-force` are machine-wide Docker cleanup commands.
- `nuke` removes containers, images, and volumes with separate Docker commands.
- `cleanm core` deletes migration files for the `core` app and regenerates them.
- `pycache` removes `__pycache__` folders and `.pyc`/`.pyo` files from the repo.

## Notes

- The commands run inside the `app` Docker service.
- Your Python environment is expected to live inside Docker, not on the host.
- If you want the full list of available targets, run:

```powershell
.\make.ps1 help
```
