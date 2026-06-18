# Install batch-3 skills: reference packs, context-engineering, ai-prompt-engineering, workflow-gate junctions.
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
$templatesRules = Join-Path $env:USERPROFILE '.ai-workspace\templates\rules'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    if ($DryRun) { Write-Host "[dry-run] write $Path"; return }
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        Remove-Item -LiteralPath $Path -Force
    }
    elseif ($item.PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    else {
        Remove-Item -LiteralPath $Path -Force
    }
}

function New-SkillJunction {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )
    if (-not (Test-Path $TargetPath)) {
        Write-Warning "Target missing, skip junction: $TargetPath"
        return $false
    }
    if ($DryRun) {
        Write-Host "[dry-run] junction $LinkPath -> $TargetPath"
        return $true
    }
    Remove-LinkOrDir -Path $LinkPath
    New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
    return $true
}

function Copy-SkillToTargets {
    param(
        [string]$Name
    )
    $src = Join-Path $cursorSkills $Name
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "Skip mirror; missing skill dir: $src"
        return
    }
    $srcResolved = (Resolve-Path -LiteralPath $src).Path
    foreach ($destRoot in @($claudeSkills, $codexSkills)) {
        if (-not (Test-Path $destRoot)) {
            if (-not $DryRun) { New-Item -ItemType Directory -Path $destRoot -Force | Out-Null }
        }
        $dest = Join-Path $destRoot $Name
        if ($DryRun) {
            Write-Host "[dry-run] junction mirror $Name -> $destRoot"
            continue
        }
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $srcResolved | Out-Null
    }
}

# --- claude-code-prompts-reference ---
$ccRef = Join-Path $cursorSkills 'claude-code-prompts-reference'
if (-not $DryRun) { New-Item -ItemType Directory -Path $ccRef -Force | Out-Null }
New-SkillJunction -LinkPath (Join-Path $ccRef 'patterns') -TargetPath (Join-Path $vendor 'claude-code-prompts\patterns')
New-SkillJunction -LinkPath (Join-Path $ccRef 'skills') -TargetPath (Join-Path $vendor 'claude-code-prompts\skills')
New-SkillJunction -LinkPath (Join-Path $ccRef 'complete-prompts') -TargetPath (Join-Path $vendor 'claude-code-prompts\complete-prompts')

$ccRefSkill = @'
---
name: claude-code-prompts-reference
description: Read-only reference for repowise-dev/claude-code-prompts patterns and sub-skills. Use when studying Claude Code prompt architecture — not for routine coding.
disable-model-invocation: true
---
# Claude Code Prompts Reference

Source: https://github.com/repowise-dev/claude-code-prompts (vendor mirror under `~/.ai-workspace/vendor/claude-code-prompts/`)

## When to Read

- Designing agent system/tool prompts
- Comparing verification or delegation patterns
- Fixing weak prompt structure (read `skills/prompt-architect/`)

## Contents (local)

| Path | Use |
|------|-----|
| `patterns/` | Pattern analyses with reusable templates |
| `skills/coding-agent-standards/` | Implementation discipline |
| `skills/prompt-architect/` | Prompt design methodology |
| `skills/verification-agent/` | Risk-based verification (reference only) |
| `complete-prompts/` | Full prompt templates |

## Do NOT duplicate at runtime

- P5 self-review: use `agent-verifier` + `verification-before-completion`, not vendor verification-agent as always-on.
- Routine delivery: use `workflow-gate` + `global-delivery-gate`.
'@
Write-Utf8NoBomFile -Path (Join-Path $ccRef 'SKILL.md') -Content $ccRefSkill

# --- most-capable-agent-reference ---
$mcRef = Join-Path $cursorSkills 'most-capable-agent-reference'
if (-not $DryRun) { New-Item -ItemType Directory -Path $mcRef -Force | Out-Null }
New-SkillJunction -LinkPath (Join-Path $mcRef 'vendor') -TargetPath (Join-Path $vendor 'most-capable-agent')

$mcRefSkill = @'
---
name: most-capable-agent-reference
description: Read-only reference for fainir most-capable-agent system prompt patterns. Use when studying agent prompt architecture — not for routine coding.
disable-model-invocation: true
---
# Most Capable Agent Reference

Source: https://github.com/fainir/most-capable-agent-system-prompt

## When to Read

- Designing long-horizon agent harnesses
- Studying self-improvement / task-graph / verification loops
- Need full "The Prompt" text (do not load into always-on context)

## Local files

| File | Content |
|------|---------|
| `vendor/README.md` | Full system prompt in `## The Prompt` section |
| `vendor/most_capable_agent_system_architecture.svg` | Architecture diagram |

## Global condensed base

The operational subset lives in `~/.claude/AGENTS.md` § Project Brain + `workflow-gate` skill. Read this reference only on demand.
'@
Write-Utf8NoBomFile -Path (Join-Path $mcRef 'SKILL.md') -Content $mcRefSkill

$archMd = @'
# Most Capable Agent Architecture

See diagram: `vendor/most_capable_agent_system_architecture.svg`

Read full prompt: `vendor/README.md` section **The Prompt**.

For day-to-day coding, follow `workflow-gate` six phases instead of pasting the full prompt.
'@
Write-Utf8NoBomFile -Path (Join-Path $mcRef 'ARCHITECTURE.md') -Content $archMd

$promptPointer = @'
# Full System Prompt

Open and read:

`~/.ai-workspace/vendor/most-capable-agent/README.md`

Section: **## The Prompt** (intentionally not duplicated here to save tokens).
'@
Write-Utf8NoBomFile -Path (Join-Path $mcRef 'PROMPT.md') -Content $promptPointer

# --- context-engineering (from PAIPlugin prompting, renamed) ---
$ctxDir = Join-Path $cursorSkills 'context-engineering'
if (-not $DryRun) { New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null }

$ctxSkill = @'
---
name: context-engineering
description: Context engineering and prompt structure standards — signal-to-noise, progressive discovery, just-in-time loading. Use for agent configuration and prompt design questions.
disable-model-invocation: true
---
# Context Engineering

Based on Anthropic context engineering best practices (via danielmiessler/PAIPlugin prompting skill).

## When to Activate

- Context engineering guidance
- Prompt structure help
- Reducing token noise in agent instructions
- Agent configuration / skill design

## Core Philosophy

**Context engineering** = curating the optimal token set during inference.

**Goal:** smallest high-signal token set that maximizes outcomes.

## Key Principles

1. **Context is finite** — every token depletes attention budget.
2. **Optimize signal-to-noise** — direct language; remove redundancy.
3. **Progressive discovery** — identifiers first; load details on demand.

## Markdown Structure

- **Background**: minimal essential context
- **Instructions**: imperative, specific, actionable
- **Examples**: concise, representative
- **Constraints**: boundaries and success criteria

## Writing Style

- Clarity over completeness
- Direct imperatives, not "you might consider"
- Bulleted constraints, not paragraph requirements

## Anti-Patterns

- Verbose explanations and history dumps
- Overlapping tool definitions
- Premature full-data loading
- Vague modals ("might", "could", "should")

## Related

- Production prompt patterns: `ai-prompt-engineering`
- Workflow phases: `workflow-gate`
'@
Write-Utf8NoBomFile -Path (Join-Path $ctxDir 'SKILL.md') -Content $ctxSkill

# --- ai-prompt-engineering (operational summary; vendor path optional) ---
$peDir = Join-Path $cursorSkills 'ai-prompt-engineering'
if (-not $DryRun) { New-Item -ItemType Directory -Path $peDir -Force | Out-Null }

$peSkill = @'
---
name: ai-prompt-engineering
description: Operational prompt engineering patterns for production agents — structured outputs, RAG, tool planners, eval gates. Use when writing or debugging production prompts.
disable-model-invocation: true
---
# Prompt Engineering — Operational Skill

Production-ready patterns (December 2025+): versioned prompts, output contracts, regression tests, safety threat modeling.

## When to Use

- Write or improve a production-ready prompt
- Debug inconsistent LLM outputs
- Structured outputs (JSON, tables, schemas)
- RAG pipelines with grounding
- Agent workflows with tool calling
- Validate prompt quality before deployment

## Quick Reference

| Task | Pattern | Key components |
|------|---------|----------------|
| Machine-parseable output | Structured Output | JSON schema, JSON-only directive |
| Field extraction | Deterministic Extractor | exact schema, missing→null |
| Retrieved context | RAG Workflow | relevance check, citations |
| Hidden reasoning | Hidden CoT | internal reasoning, final answer only |
| Tool-using agent | Tool/Agent Planner | plan-then-act, one tool per turn |
| Text transform | Rewrite + Constrain | style rules, meaning preserved |
| Classification | Decision Tree | ordered branches, JSON result |

## Decision Tree

1. Output must be machine-readable?
   - Extract fields only → Deterministic Extractor
   - Generate structured data → Structured Output (JSON)
2. Use external knowledge? → RAG Workflow
3. Reasoning hidden? → Hidden CoT
4. External tools/APIs? → Tool/Agent Planner
5. Transform text? → Rewrite + Constrain
6. Route categories? → Decision Tree

## Do

- Keep prompts small and modular
- Add eval harness; block regressions
- Prefer brief justification over visible chain-of-thought
- Positive framing for desired behavior

## Avoid

- Prompt sprawl without owner/tests
- Brittle multi-step chains without validation
- Mixing policy and product copy in one prompt

## Related

- Context principles: `context-engineering`
- Reference templates: `claude-code-prompts-reference` → `skills/prompt-architect/`
'@
Write-Utf8NoBomFile -Path (Join-Path $peDir 'SKILL.md') -Content $peSkill

# --- workflow-gate ---
$wgDir = Join-Path $cursorSkills 'workflow-gate'
if (-not $DryRun) { New-Item -ItemType Directory -Path $wgDir -Force | Out-Null }

$wgSkill = @'
---
name: workflow-gate
description: ALWAYS apply — six-phase workflow gate with approval between architecture, interface design, and implementation. Maps to requirement-clarifier, zero-to-one-gate, and global-delivery-gate.
disable-model-invocation: false
---
# Workflow Gate — Six Phases

Applies to **Cursor, Claude Code, Codex**. Unified gate for spec-driven delivery.

## Tiers

| Tier | When | Path |
|------|------|------|
| **A — Strict** | New module, cross-file flow, no ADR, 帮我做… | P1→P2→P3→approval→P4→P5→P6 |
| **B — Fast** | Typo, copy, single-line fix, user says 直接做/就改这一处 | P1 lite → P4 → P5 → P6 |

## Phases

| Phase | Name | Skills / artifacts | Approval required |
|-------|------|-------------------|-------------------|
| P1 | Requirements clarification | `requirement-clarifier` | Tier A: Mini-Spec confirm; Tier B: skip if user said 直接做 |
| P2 | Architecture design | `zero-to-one-gate`, `brainstorming`, ADR in `decisions-log.md` | **Yes** before P3 |
| P3 | Interface design | `DESIGN.md` or `docs/architecture/*` with interface contracts | **Yes** before P4 |
| P4 | Implementation | Minimal diff; match repo conventions | After P3 or Tier B skip |
| P5 | Self-review | `agent-verifier` or structured self-review checklist | Before claim done |
| P6 | Refactor + Verify | `global-delivery-gate`; run detected verify commands | Fresh evidence required |

## Approval keywords (align with clarification gate)

User may advance with: 确认执行, 开始执行, 按默认建议, 确认, 可以执行, 按澄清结果执行.

## Before any code (Project Brain)

1. Design module boundaries
2. Define data flow
3. Identify failure points
4. Produce architecture plan

**Never write implementation without design approval** (Tier A). Exceptions: Tier B fast path only.

## Outputs by phase

- P2: ADR entry + 2–3 options + recommendation (≤15 lines summary)
- P3: Interface contract table (inputs, outputs, errors, owners)
- P6: Completed / Verified / Remaining Risks

## Cross-references

- 0→1 detail: `zero-to-one-gate`
- Plans: `writing-plans` or `planning-with-files-zh`
- Prototype delivery: `ai-delivery-gate` instead of `global-delivery-gate`
'@
Write-Utf8NoBomFile -Path (Join-Path $wgDir 'SKILL.md') -Content $wgSkill

# Mirror new skills to Claude + Codex
foreach ($n in @(
        'claude-code-prompts-reference',
        'most-capable-agent-reference',
        'context-engineering',
        'ai-prompt-engineering',
        'workflow-gate'
    )) {
    Copy-SkillToTargets -Name $n
}

Write-Host 'Batch-3 skill install complete.'
if ($DryRun) { Write-Host '(dry-run only)' }
