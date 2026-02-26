  param(
    [Parameter(Mandatory = $true)]
    [string]$PromptText,

    [string]$CompletionPromise = "DONE",

    [int]$MaxIterations = 10,

    [string]$OutputRoot = "C:\.codex\loopback.outputs",

    [switch]$SkipGitRepoCheck = $true
  )

  $ErrorActionPreference = "Stop"

  function Test-CodexInstalled {
    $cmd = Get-Command codex -ErrorAction SilentlyContinue
    if (-not $cmd) {
      throw "codex CLI not found in PATH."
    }
  }

  function Write-IterationLog {
    param(
      [int]$Iteration,
      [string]$Content
    )
    $logPath = Join-Path $OutputRoot ("iteration-{0}.log" -f
  $Iteration)
    $Content | Out-File -FilePath $logPath -Encoding utf8
    return $logPath
  }

  function Has-CompletionPromise {
    param(
      [string]$Text,
      [string]$Promise
    )
    $pattern = "<promise>\s*$([regex]::Escape($Promise))\s*</promise>"
    return [regex]::IsMatch($Text, $pattern,
  [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  }

  if ($MaxIterations -lt 1) {
    throw "MaxIterations must be >= 1."
  }

  Test-CodexInstalled
  New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

  $summaryPath = Join-Path $OutputRoot "summary.log"
  "Started: $([DateTime]::UtcNow.ToString('o'))" | Out-File -FilePath
  $summaryPath -Encoding utf8
  "MaxIterations=$MaxIterations, CompletionPromise=$CompletionPromise"
  | Add-Content -Path $summaryPath -Encoding utf8
  "" | Add-Content -Path $summaryPath -Encoding utf8

  for ($i = 1; $i -le $MaxIterations; $i++) {
    Write-Host "Running iteration $i/$MaxIterations ..."

    if ($SkipGitRepoCheck) {
      $raw = $PromptText | & codex exec --skip-git-repo-check - 2>&1
    } else {
      $raw = $PromptText | & codex exec - 2>&1
    }

    $text = ($raw | Out-String)
    $logFile = Write-IterationLog -Iteration $i -Content $text

    "Iteration $i log: $logFile" | Add-Content -Path $summaryPath
  -Encoding utf8

    if (Has-CompletionPromise -Text $text -Promise $CompletionPromise)
  {
      "Completed on iteration $i at
  $([DateTime]::UtcNow.ToString('o'))" | Add-Content -Path
  $summaryPath -Encoding utf8
      Write-Host "Completed: found <promise>$CompletionPromise</
  promise>"
      exit 0
    }
  }

  "Stopped at max iterations ($MaxIterations) at
  $([DateTime]::UtcNow.ToString('o'))" | Add-Content -Path
  $summaryPath -Encoding utf8
  Write-Host "Stopped: max iterations reached ($MaxIterations)"
  exit 1


