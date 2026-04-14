<#
  make.ps1 - Docker task runner for this Django project

  Purpose:
  - Run common Django and lint commands through the app container
  - Keep local workflow aligned with docker-compose usage

  Examples:
    .\make.ps1 flake8
    .\make.ps1 test
    .\make.ps1 makemigrations
    .\make.ps1 migrate
    .\make.ps1 check
    .\make.ps1 createsuperuser
    .\make.ps1 startapp core
    .\make.ps1 manage shell
#>

param(
  [Parameter(Position = 0)]
  [ValidateSet(
    'up',
    'build',
    'rebuild',
    'down',
    'stop',
    'restart',
    'ps',
    'logs',
    'bash',
    'stop-all',
    'rm-all',
    'rmi-all',
    'rm-volumes',
    'prune',
    'prune-force',
    'prune-global',
    'prune-global-force',
    'nuke',
    'pycache',
    'flake8',
    'startproject',
    'runserver',
    'test',
    'makemigrations',
    'migrate',
    'showmigrations',
    'squashmigrations',
    'check',
    'shell',
    'dbshell',
    'collectstatic',
    'dumpdata',
    'loaddata',
    'changepassword',
    'createsuperuser',
    'startapp',
    'cleanm',
    'manage',
    'help'
  )]
  [string]$Target = 'help',

  # Optional name for app/project creation commands.
  [string]$Name = '',

  # Extra args for commands like:
  #   .\make.ps1 manage shell
  #   .\make.ps1 test core.tests
  [Parameter(ValueFromRemainingArguments)]
  [string[]]$Rest
)

$ErrorActionPreference = 'Stop'

function Invoke-DockerApp {
  param([string]$Command)

  Write-Host "-> docker-compose run --rm app sh -c \"$Command\"" -ForegroundColor Cyan
  docker-compose run --rm app sh -c $Command
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

function Invoke-DockerCompose {
  param([string[]]$CommandArgs)

  Write-Host ("-> docker-compose " + ($CommandArgs -join ' ')) -ForegroundColor Cyan
  docker-compose @CommandArgs
  if ($LASTEXITCODE -ne 0) {
    throw "docker-compose failed with exit code ${LASTEXITCODE}: $($CommandArgs -join ' ')"
  }
}

function Invoke-DockerCli {
  param([string[]]$CommandArgs)

  Write-Host ("-> docker " + ($CommandArgs -join ' ')) -ForegroundColor Cyan
  docker @CommandArgs
  if ($LASTEXITCODE -ne 0) {
    throw "docker failed with exit code ${LASTEXITCODE}: $($CommandArgs -join ' ')"
  }
}

function Stop-AllContainers {
  $containers = @(docker ps -aq)
  if ($containers.Count -eq 0) {
    Write-Host 'No containers to stop.' -ForegroundColor Yellow
    return
  }
  Invoke-DockerCli (@('stop') + $containers)
}

function Remove-AllContainers {
  $containers = @(docker ps -aq)
  if ($containers.Count -eq 0) {
    Write-Host 'No containers to remove.' -ForegroundColor Yellow
    return
  }
  Invoke-DockerCli (@('rm') + $containers)
}

function Remove-AllImages {
  $images = @(docker images -q)
  if ($images.Count -eq 0) {
    Write-Host 'No images to remove.' -ForegroundColor Yellow
    return
  }
  Invoke-DockerCli (@('rmi') + $images + @('--force'))
}

function Remove-AllVolumes {
  $volumes = @(docker volume ls -q)
  if ($volumes.Count -eq 0) {
    Write-Host 'No volumes to remove.' -ForegroundColor Yellow
    return
  }
  Invoke-DockerCli (@('volume', 'rm') + $volumes)
}

function Clear-Migrations {
  param([string]$AppName)

  if (-not $AppName) {
    $AppName = 'core'
  }

  $migrationsPath = Join-Path $PSScriptRoot (Join-Path 'app' (Join-Path $AppName 'migrations'))
  if (-not (Test-Path $migrationsPath)) {
    throw "Migrations folder not found: $migrationsPath"
  }

  Get-ChildItem -Path $migrationsPath -File |
  Where-Object { $_.Name -ne '__init__.py' } |
  Remove-Item -Force

  Write-Host "Cleared migration files in $migrationsPath" -ForegroundColor Yellow
  Invoke-DockerApp "python manage.py makemigrations $AppName"
}

function Clear-PyCache {
  $roots = @(
    $PSScriptRoot,
    (Join-Path $PSScriptRoot 'app')
  )

  foreach ($root in $roots) {
    if (-not (Test-Path $root)) {
      continue
    }

    Get-ChildItem -Path $root -Recurse -Directory -Force -Filter '__pycache__' |
    Remove-Item -Recurse -Force

    Get-ChildItem -Path $root -Recurse -File -Force -Include '*.pyc', '*.pyo' |
    Remove-Item -Force
  }

  Write-Host 'Cleared Python cache files (__pycache__, .pyc, .pyo).' -ForegroundColor Yellow
}

switch ($Target) {
  'up' {
    $composeArgs = @('up') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'build' {
    $composeArgs = @('build') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'rebuild' {
    $composeArgs = @('build', '--no-cache') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'down' {
    $composeArgs = @('down') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'stop' {
    $composeArgs = @('stop') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'restart' {
    $composeArgs = @('restart') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'ps' {
    $composeArgs = @('ps') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'logs' {
    $composeArgs = @('logs') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'bash' {
    Invoke-DockerApp 'sh'
  }

  'stop-all' {
    Stop-AllContainers
  }

  'rm-all' {
    Remove-AllContainers
  }

  'rmi-all' {
    Remove-AllImages
  }

  'rm-volumes' {
    Remove-AllVolumes
  }

  'prune' {
    $composeArgs = @('down', '--volumes', '--remove-orphans', '--rmi', 'local') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'prune-force' {
    $composeArgs = @('down', '--volumes', '--remove-orphans', '--rmi', 'local', '--timeout', '0') + $Rest
    Invoke-DockerCompose -CommandArgs $composeArgs
  }

  'prune-global' {
    $dockerArgs = @('system', 'prune', '-a', '--volumes') + $Rest
    Invoke-DockerCli -CommandArgs $dockerArgs
  }

  'prune-global-force' {
    $dockerArgs = @('system', 'prune', '-a', '--volumes', '-f') + $Rest
    Invoke-DockerCli -CommandArgs $dockerArgs
  }

  'nuke' {
    Stop-AllContainers
    Remove-AllContainers
    Remove-AllImages
    Remove-AllVolumes
  }

  'pycache' {
    Clear-PyCache
  }

  'flake8' {
    Invoke-DockerApp 'flake8'
  }

  'startproject' {
    $projectName = if ($Name) { $Name } elseif ($Rest.Count -ge 1) { $Rest[0] } else { 'app' }
    Invoke-DockerApp "django-admin startproject $projectName ."
  }

  'runserver' {
    $bind = if ($Rest.Count -gt 0) { ($Rest -join ' ') } else { '0.0.0.0:8000' }
    Invoke-DockerApp "python manage.py runserver $bind"
  }

  'shell' {
    Invoke-DockerApp 'python manage.py shell'
  }

  'dbshell' {
    Invoke-DockerApp 'python manage.py dbshell'
  }

  'test' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py test$extra"
  }

  'makemigrations' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py makemigrations$extra"
  }

  'migrate' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py migrate$extra"
  }

  'showmigrations' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py showmigrations$extra"
  }

  'squashmigrations' {
    if ($Rest.Count -lt 2) {
      throw 'Usage: .\make.ps1 squashmigrations <app_label> <migration_name>'
    }
    Invoke-DockerApp ("python manage.py squashmigrations " + ($Rest -join ' '))
  }

  'check' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py check$extra"
  }

  'collectstatic' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { ' --noinput' }
    Invoke-DockerApp "python manage.py collectstatic$extra"
  }

  'dumpdata' {
    $extra = if ($Rest.Count -gt 0) { " " + ($Rest -join ' ') } else { '' }
    Invoke-DockerApp "python manage.py dumpdata$extra"
  }

  'loaddata' {
    if ($Rest.Count -lt 1) {
      throw 'Usage: .\make.ps1 loaddata <fixture.json>'
    }
    Invoke-DockerApp ("python manage.py loaddata " + ($Rest -join ' '))
  }

  'createsuperuser' {
    Invoke-DockerApp 'python manage.py createsuperuser'
  }

  'changepassword' {
    if ($Rest.Count -lt 1) {
      throw 'Usage: .\make.ps1 changepassword <username>'
    }
    Invoke-DockerApp ("python manage.py changepassword " + ($Rest -join ' '))
  }

  'startapp' {
    $appName = if ($Name) { $Name } elseif ($Rest.Count -ge 1) { $Rest[0] } else { 'core' }
    Invoke-DockerApp "python manage.py startapp $appName"
  }

  'cleanm' {
    $appName = if ($Name) { $Name } elseif ($Rest.Count -ge 1) { $Rest[0] } else { 'core' }
    Clear-Migrations -AppName $appName
  }

  'manage' {
    if ($Rest.Count -eq 0) {
      throw 'Usage: .\make.ps1 manage <manage.py args...>'
    }
    Invoke-DockerApp ("python manage.py " + ($Rest -join ' '))
  }

  'help' {
    Write-Host @'
Targets:
  up [args...]             (e.g. --build, -d)
  build [args...]
  rebuild [args...]        (build --no-cache)
  down [args...]
  stop [args...]
  restart [args...]
  ps [args...]
  logs [args...]
  bash                     (open shell in app container)
  stop-all                 (stop all containers)
  rm-all                   (remove all containers)
  rmi-all                  (remove all images, forced)
  rm-volumes               (remove all volumes)
  prune [args...]          (project only: compose down --volumes --remove-orphans --rmi local)
  prune-force [args...]    (project only, fast stop: same as prune + --timeout 0)
  prune-global [args...]   (docker system prune -a --volumes)
  prune-global-force [args...] (docker system prune -a --volumes -f)
  nuke                     (stop-all -> rm-all -> rmi-all -> rm-volumes)
  pycache                  (remove __pycache__ folders and .pyc/.pyo files)
  flake8
  startproject [name]      (default: app)
  runserver [addr:port]    (default: 0.0.0.0:8000)
  shell
  dbshell
  test [labels...]
  makemigrations [app...]
  migrate [args...]
  showmigrations [app...]
  squashmigrations <app_label> <migration_name>
  check [args...]
  collectstatic [args...]  (default: --noinput)
  dumpdata [args...]
  loaddata <fixture.json>
  createsuperuser
  changepassword <username>
  startapp [name]          (default: core)
  cleanm [app]             (delete migration files and remake them)
  manage <args...>         (pass-through to python manage.py)

Examples:
  .\make.ps1 up
  .\make.ps1 up --build
  .\make.ps1 up -d
  .\make.ps1 build
  .\make.ps1 rebuild
  .\make.ps1 down
  .\make.ps1 stop
  .\make.ps1 restart
  .\make.ps1 ps
  .\make.ps1 logs -f app
  .\make.ps1 bash
  .\make.ps1 stop-all
  .\make.ps1 rm-all
  .\make.ps1 rmi-all
  .\make.ps1 rm-volumes
  .\make.ps1 prune
  .\make.ps1 prune-force
  .\make.ps1 prune-global
  .\make.ps1 prune-global-force
  .\make.ps1 nuke
  .\make.ps1 pycache
  .\make.ps1 flake8
  .\make.ps1 startproject app
  .\make.ps1 runserver
  .\make.ps1 shell
  .\make.ps1 dbshell
  .\make.ps1 test
  .\make.ps1 makemigrations
  .\make.ps1 migrate
  .\make.ps1 showmigrations
  .\make.ps1 collectstatic
  .\make.ps1 loaddata fixtures/data.json
  .\make.ps1 check
  .\make.ps1 createsuperuser
  .\make.ps1 changepassword admin
  .\make.ps1 startapp core
  .\make.ps1 cleanm core
  .\make.ps1 manage shell
'@
  }
}
