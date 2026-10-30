# Safely merge this Lab 02 package into your Windows Git repository

These steps are designed for the repository at `D:\04_Lab\Docker\linux-container-internals`. They do not commit or push anything.

## 1. Make a backup first

Open PowerShell and run:

```powershell
cd D:\04_Lab\Docker\linux-container-internals
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item .\labs\lab02-cgroups ".\labs\lab02-cgroups-backup-$stamp" -Recurse
```

Check that the backup exists before continuing:

```powershell
Get-ChildItem .\labs -Directory | Where-Object Name -Like 'lab02-cgroups-backup-*'
```

## 2. Remove accidental files only after verifying their names

The earlier terminal log showed files named `tatus --short` and `tore --source=HEAD -- preflight.sh` at the repository root. Inspect them first:

```powershell
Get-Item -LiteralPath '.\tatus --short', '.\tore --source=HEAD -- preflight.sh' -ErrorAction SilentlyContinue
```

If these are confirmed accidental files created by pasting commands into the prompt, remove only those exact files:

```powershell
Remove-Item -LiteralPath '.\tatus --short' -ErrorAction SilentlyContinue
Remove-Item -LiteralPath '.\tore --source=HEAD -- preflight.sh' -ErrorAction SilentlyContinue
```

Do not delete any file unless you confirm it is an accidental artifact.

## 3. Extract the package to a temporary location

Extract the ZIP supplied with this package somewhere outside the repository, then compare the extracted `lab02-cgroups` directory against `labs\lab02-cgroups`. Keep the existing `preflight.sh` and all original files until you have checked the backup.

The ZIP is organized as `lab02-cgroups\...`; copy the *contents* into the existing `labs\lab02-cgroups\` folder only after the comparison. Do not replace the whole repository or any parent folder.

## 4. Review Git state

From the repository root:

```powershell
git status --short
git diff --check
git diff --cached --check
git diff --stat
git diff --cached --stat
```

`LF will be replaced by CRLF` is a line-ending warning, not a whitespace failure. A `trailing whitespace` message is a separate issue and should be fixed.

If the index contains confusing staged additions/deletions, unstage only the Lab 02 paths while preserving working-tree files:

```powershell
git restore --staged -- labs/lab02-cgroups
```

This changes the index only; it does not restore or delete the files in your working tree. Run `git status --short` again and inspect every path before staging anything.

## 5. Stage only intended Lab 02 files

From repository root, stage the known intended files explicitly after reviewing their contents:

```powershell
git add labs/lab02-cgroups/README.md `
        labs/lab02-cgroups/commands.md `
        labs/lab02-cgroups/evidence.md `
        labs/lab02-cgroups/preflight.sh `
        labs/lab02-cgroups/results/2026-10-30-docker-experiment.md `
        labs/lab02-cgroups/evidence-logs `
        labs/lab02-cgroups/screenshots `
        labs/lab02-cgroups/APPLY-TO-REPO-WINDOWS.md
```

Then verify that no unrelated or accidental files are staged:

```powershell
git status --short
git diff --cached --check
git diff --cached --stat
```

Do not stage `labs/01-environment.png` or strange files at the repository root unless you have intentionally decided they belong in the project.

## 6. Commit only after review

Inspect the full staged diff before committing:

```powershell
git diff --cached -- labs/lab02-cgroups
```

Binary screenshots will not display as text in the diff; check their filenames and sizes with `Get-ChildItem`. Once the staged change set is correct, commit:

```powershell
git commit -m "Document Lab 02 cgroups v2 CPU and memory experiments"
```

Push only if you intend to publish the commit and your branch/upstream are correct:

```powershell
git status -sb
git push
```

**This package does not itself modify your local repository or push to GitHub.** The lab remains in progress until missing experiments/evidence are completed.
