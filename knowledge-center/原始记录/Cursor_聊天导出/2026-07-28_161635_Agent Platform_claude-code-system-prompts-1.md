Source URL: https://github.com/piebald-ai/claude-code-system-prompts?utm_source=chatgpt.com
Title: GitHub - Piebald-AI/claude-code-system-prompts: All parts of Claude Code's system prompt, 27 builtin tool descriptions, sub agent prompts (Plan/Explore/Task), utility prompts (CLAUDE.md, compact,  statusline, magic docs, WebFetch, Bash cmd, security review, agent creation).  Updated for each Claude Code version. · GitHub

Skip to content 

## Navigation Menu

Toggle navigation 

 Sign in 

Appearance settings 

* Platform  
   * AI CODE CREATION  
         * GitHub CopilotWrite better code with AI  
         * GitHub Copilot appDirect agents from issue to merge  
         * MCP RegistryNewIntegrate external tools  
   * DEVELOPER WORKFLOWS  
         * ActionsAutomate any workflow  
         * CodespacesInstant dev environments  
         * IssuesPlan and track work  
         * Code ReviewManage code changes  
   * APPLICATION SECURITY  
         * GitHub Advanced SecurityFind and fix vulnerabilities  
         * Code securitySecure your code as you build  
         * Secret protectionStop leaks before they start  
   * EXPLORE  
         * Why GitHub  
         * Documentation  
         * Blog  
         * Changelog  
         * Marketplace  
View all features
* Solutions  
   * BY COMPANY SIZE  
         * Enterprises  
         * Small and medium teams  
         * Startups  
         * Nonprofits  
   * BY USE CASE  
         * App Modernization  
         * DevSecOps  
         * DevOps  
         * CI/CD  
         * View all use cases  
   * BY INDUSTRY  
         * Healthcare  
         * Financial services  
         * Manufacturing  
         * Government  
         * View all industries  
View all solutions
* Resources  
   * EXPLORE BY TOPIC  
         * AI  
         * Software Development  
         * DevOps  
         * Security  
         * View all topics  
   * EXPLORE BY TYPE  
         * Customer stories  
         * Events & webinars  
         * Ebooks & reports  
         * Business insights  
         * GitHub Skills  
   * SUPPORT & SERVICES  
         * Documentation  
         * Customer support  
         * Community forum  
         * Trust center  
         * Partners  
View all resources
* Open Source  
   * COMMUNITY  
         * GitHub SponsorsFund open source developers  
   * PROGRAMS  
         * Security Lab  
         * Maintainer Community  
         * Accelerator  
         * GitHub Stars  
         * Archive Program  
   * REPOSITORIES  
         * Topics  
         * Trending  
         * Collections
* Enterprise  
   * ENTERPRISE SOLUTIONS  
         * Enterprise platformAI-powered developer platform  
   * AVAILABLE ADD-ONS  
         * GitHub Advanced SecurityEnterprise-grade security features  
         * Copilot for BusinessEnterprise-grade AI features  
         * Premium SupportEnterprise-grade 24/7 support
* Pricing

Search or jump to... 

# Search code, repositories, users, issues, pull requests...

 Search 

Clear 

Search syntax tips 

#  Provide feedback

We read every piece of feedback, and take your input very seriously.

Include my email address so I can be contacted 

 Cancel  Submit feedback 

#  Saved searches

## Use saved searches to filter your results more quickly

Name 

Query 

 To see all available qualifiers, see our documentation.

 Cancel  Create saved search 

 Sign in 

 Sign up 

Appearance settings 

Resetting focus 

You signed in with another tab or window. Reload to refresh your session. You signed out in another tab or window. Reload to refresh your session. You switched accounts on another tab or window. Reload to refresh your session. Dismiss alert 

{{ message }}

 Piebald-AI / **claude-code-system-prompts** Public 

* Notifications You must be signed in to change notification settings
* Fork1.9k
* Star 11.1k

* Code
* Issues 4
* Pull requests 3
* Discussions
* Actions
* Security and quality 0
* Insights

Additional navigation options 

* Code
* Issues
* Pull requests
* Discussions
* Actions
* Security and quality
* Insights

# Piebald-AI/claude-code-system-prompts

main

BranchesTags

Go to file

Code

Open more actions menu

## Folders and files

| Name                                                                                                | Name                                                                                               | Last commit message | Last commit date |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ------------------- | ---------------- |
| Latest commit History[456 Commits](/Piebald-AI/claude-code-system-prompts/commits/main/)456 Commits |                                                                                                    |                     |                  |
| [system-prompts](/Piebald-AI/claude-code-system-prompts/tree/main/system-prompts "system-prompts")  | [system-prompts](/Piebald-AI/claude-code-system-prompts/tree/main/system-prompts "system-prompts") |                     |                  |
| [tools](/Piebald-AI/claude-code-system-prompts/tree/main/tools "tools")                             | [tools](/Piebald-AI/claude-code-system-prompts/tree/main/tools "tools")                            |                     |                  |
| [.gitignore](/Piebald-AI/claude-code-system-prompts/blob/main/.gitignore ".gitignore")              | [.gitignore](/Piebald-AI/claude-code-system-prompts/blob/main/.gitignore ".gitignore")             |                     |                  |
| [CHANGELOG.md](/Piebald-AI/claude-code-system-prompts/blob/main/CHANGELOG.md "CHANGELOG.md")        | [CHANGELOG.md](/Piebald-AI/claude-code-system-prompts/blob/main/CHANGELOG.md "CHANGELOG.md")       |                     |                  |
| [CLAUDE.md](/Piebald-AI/claude-code-system-prompts/blob/main/CLAUDE.md "CLAUDE.md")                 | [CLAUDE.md](/Piebald-AI/claude-code-system-prompts/blob/main/CLAUDE.md "CLAUDE.md")                |                     |                  |
| [LICENSE](/Piebald-AI/claude-code-system-prompts/blob/main/LICENSE "LICENSE")                       | [LICENSE](/Piebald-AI/claude-code-system-prompts/blob/main/LICENSE "LICENSE")                      |                     |                  |
| [README.md](/Piebald-AI/claude-code-system-prompts/blob/main/README.md "README.md")                 | [README.md](/Piebald-AI/claude-code-system-prompts/blob/main/README.md "README.md")                |                     |                  |
| View all files                                                                                      |                                                                                                    |                     |                  |

## Repository files navigation

* README
* MIT license

### Check out Piebald

We've released **Piebald**, the ultimate agentic AI developer experience.   
Download it and try it out for free! **<https://piebald.ai/>**

Join our Discord X

**Scroll down for Claude Code's system prompts.** 👇

hero 

# Claude Code System Prompts

Mentioned in Awesome Claude Code

Tip

**NEW (June 12, 2026):** We've greatly expanded this list with many more of Claude Code's prompts—**from 350 to 515 (+165)**—our most complete coverage yet.

This repository contains an up-to-date list of all Claude Code's various system prompts and their associated token counts as of **Claude Code v2.1.178 (June 15th, 2026).** It also contains a **CHANGELOG.md** for the system prompts across 211 versions since v2.0.14\. From the team behind **Piebald.**

**This repository is updated within minutes of each Claude Code release. See the changelog, and follow @PiebaldAI on X for a summary of the system prompt changes in each release.**

Note

⭐ **Star** this repository to get notified about new Claude Code versions. For each new Claude Code version, we create a release on GitHub, which will notify all users who've starred the repository.

---

Why multiple "system prompts?"

**Claude Code doesn't just have one single string for its system prompt.**

Instead, there are:

* Large portions conditionally added depending on the environment and various configs.
* Descriptions for builtin tools like `Write`, `Bash`, and `TodoWrite`, and some are fairly large.
* Separate system prompts for builtin agents like Explore and Plan.
* Numerous AI-powered utility functions, such as conversation compaction, `CLAUDE.md` generation, session title generation, etc. featuring their own systems prompts.

The result—500+ strings that are constantly changing and moving within a very large minified JS file.

Important

Want to **modify a particular piece of the system prompt** in your own Claude Code installation? **Use tweakcc.** It—

* lets you customize the individual pieces of the system prompt as markdown files, and then
* patches your npm-based or native (binary) Claude Code installation with them, and also
* provides diffing and conflict management for when both you and Anthropic have conflicting modifications to the same prompt file.

## Extraction

This repository contains the system prompts extracted using a script from the latest npm version of Claude Code. As they're extracted directly from Claude Code's compiled source code, they're guaranteed to be exactly what Claude Code uses. If you use tweakcc to customize the system prompts, it works in a similar way—it patches the exact same strings in your local installation as are extracted into this repository.

## Prompts

Note that some prompts contain interpolated bits such as builtin tool name references, lists of available sub agents, and various other context-specific variables, so the actual counts in a particular Claude Code session will differ slightly—likely not beyond ±20 tokens, however.

### Agent Prompts

Sub-agents and utilities.

#### Sub-agents

* Agent Prompt: Explore (**575** tks) - System prompt for the Explore subagent.
* Agent Prompt: Plan mode (enhanced) (**715** tks) - Enhanced prompt for the Plan subagent.

#### Creation Assistants

* Agent Prompt: Agent creation architect (**1110** tks) - System prompt for creating custom AI agents with detailed specifications.
* Agent Prompt: CLAUDE.md creation (**384** tks) - System prompt for analyzing codebases and creating CLAUDE.md documentation files.
* Agent Prompt: Status line setup (**2433** tks) - System prompt for the statusline-setup agent that configures status line display.

#### Slash Commands

* Agent Prompt: /batch slash command (**1106** tks) - Instructions for orchestrating a large, parallelizable change across a codebase.
* Agent Prompt: /code-review part 1 base finder angles (**145** tks) - Line-by-line diff scan instructions for the /code-review slash command's finder-angle phase.
* Agent Prompt: /code-review part 2 low effort mode (**345** tks) - Low-effort /code-review prompt that reads the diff once and returns up to four hunk-visible runtime correctness findings.
* Agent Prompt: /code-review part 3 extra-high and maximum effort modes (**0** tks) - Extra-high and maximum-effort /code-review prompt that runs five finder angles, one-vote verification, a gap sweep, and capped JSON findings.
* Agent Prompt: /code-review part 4 three-state verification phase (**98** tks) - Verification phase for /code-review that asks one agent verifier to classify each candidate as confirmed, plausible, or refuted.
* Agent Prompt: /code-review part 5 recall-biased verification phase (**175** tks) - Recall-biased /code-review verification phase that treats realistic uncertain findings as plausible unless code refutes them.
* Agent Prompt: /code-review part 6 medium effort mode (**0** tks) - Medium-effort /code-review prompt that favors precision with three finder angles, one-vote verification, and up to eight JSON findings.
* Agent Prompt: /code-review part 7 high effort mode (**0** tks) - High-effort /code-review prompt that favors recall with three finder angles, recall-biased verification, and up to ten JSON findings.
* Agent Prompt: /code-review part 8 GitHub comment posting (**152** tks) - Optional /code-review instructions for posting findings as GitHub inline PR comments when --comment is passed.
* Agent Prompt: /code-review part 9 fix application (**126** tks) - Optional /code-review instructions for applying findings to the working tree when --fix is passed.
* Agent Prompt: /rename auto-generate session name (**80** tks) - Prompt used by /rename (no args) to auto-generate a kebab-case session name from conversation context.
* Agent Prompt: /review-pr slash command (**235** tks) - System prompt for reviewing GitHub pull requests with code analysis.
* Agent Prompt: /schedule slash command (**3131** tks) - Guides the user through scheduling, updating, listing, or running remote Claude Code agents on cron triggers via the Anthropic cloud API.
* Agent Prompt: /security-review slash command (**2521** tks) - Comprehensive security review prompt for analyzing code changes with focus on exploitable vulnerabilities.
* Agent Prompt: /simplify slash command (**362** tks) - Instructions for the /simplify slash command that reviews changed code for reuse, simplification, efficiency, and altitude cleanups, then applies the fixes.

#### Utilities

* Agent Prompt: Agent Hook (**122** tks) - Prompt for an 'agent hook'.
* Agent Prompt: Auto mode rule reviewer (**292** tks) - Reviews and critiques user-defined auto mode classifier rules for clarity, completeness, conflicts, and actionability.
* Agent Prompt: Away summary generation (**73** tks) - Prompts a no-tools away-summary generation run to recap the goal, current task, and next action when the user returns.
* Agent Prompt: Background agent state classifier (**4405** tks) - Classifies the tail of a background agent transcript as working, blocked, done, or failed and returns concise state JSON.
* Agent Prompt: Background job agent instructions (**427** tks) - Instructs the built-in background job agent to narrate progress, restate tool results, and emit explicit result, needs input, or failed status signals.
* Agent Prompt: Bash command description writer (**207** tks) - Instructions for generating clear, concise command descriptions in active voice for bash commands.
* Agent Prompt: Bash command prefix detection (**823** tks) - System prompt for detecting command prefixes and command injection.
* Agent Prompt: Claude Code guide (**143** tks) - Subagent that answers Claude Code feature/SDK/API questions.
* Agent Prompt: Claude guide agent (**833** tks) - System prompt for the claude-guide agent that helps users understand and use Claude Code, the Claude Agent SDK and the Claude API effectively.
* Agent Prompt: Coding session title generator (**314** tks) - Generates a title for the coding session.
* Agent Prompt: Conversation summarization (**1201** tks) - System prompt for creating detailed conversation summaries.
* Agent Prompt: Determine which memory files to attach (**271** tks) - Agent for determining which memory files to attach for the main agent.
* Agent Prompt: Dream memory consolidation (**859** tks) - Instructs an agent to perform a multi-phase memory consolidation pass — orienting on existing memories, gathering recent signal from logs and transcripts, merging updates into topic files, and pruning the index.
* Agent Prompt: Dream memory pruning (**456** tks) - Instructs an agent to perform a memory pruning pass by deleting stale or invalidated memory files and collapsing duplicates in the memory directory.
* Agent Prompt: General purpose agent (**63** tks) - Defines a general-purpose agent for researching complex questions, searching code, and executing multi-step tasks.
* Agent Prompt: General purpose (**285** tks) - System prompt for the general-purpose subagent that searches, analyzes, and edits code across a codebase while reporting findings concisely to the caller.
* Agent Prompt: General task agent (**99** tks) - Instructs a Claude Code task agent to complete the user's request fully and report the essential outcome.
* Agent Prompt: Hook condition evaluator (stop) (**319** tks) - System prompt for evaluating hook conditions, specifically stop conditions, in Claude Code.
* Agent Prompt: Hook condition evaluator (**88** tks) - Instructs an agent to judge whether a user-provided hook condition is met.
* Agent Prompt: Inherited context for worktree sub-agent (**121** tks) - Briefs a sub-agent that it has inherited a parent session's context and is now working in its own isolated git worktree.
* Agent Prompt: Managed Agents onboarding flow (**2785** tks) - Interactive interview script that helps users configure a Managed Agent by describing the task, proposing tools and resources, setting up the environment and session, testing access, and emitting integration code.
* Agent Prompt: Memory synthesis (**449** tks) - Subagent that reads persistent memory files and returns a JSON synthesis of only the information relevant to each query, with cited filenames.
* Agent Prompt: Onboarding guide draft share link workflow (**323** tks) - Adds instructions for sharing the draft ONBOARDING.md before review, then updating the same ShareOnboardingGuide link after the user answers the review questions.
* Agent Prompt: Onboarding guide generator (**1135** tks) - Co-authors a team onboarding guide (ONBOARDING.md) for new Claude Code users by analyzing the creator's usage data, classifying session types, and iterating on the draft collaboratively.
* Agent Prompt: PR follow-up cron (**172** tks) - Cron prompt for checking a pull request created in the session and fixing failures, comments, or conflicts.
* Agent Prompt: Prompt Suggestion Generator v2 (**344** tks) - V2 instructions for generating prompt suggestions for Claude Code.
* Agent Prompt: Quick PR creation (**986** tks) - Streamlined prompt for creating a commit and pull request with pre-populated context.
* Agent Prompt: Read-only search agent (**93** tks) - Defines a read-only search agent for broad fan-out code searches that returns conclusions instead of file dumps.
* Agent Prompt: Recent Message Summarization (**804** tks) - Agent prompt used for summarizing recent messages.
* Agent Prompt: Schedule action selection (**114** tks) - Instructs the cloud scheduling agent to ask the user which schedule action to perform first.
* Agent Prompt: Security monitor for autonomous agent actions (first part) (**4897** tks) - Instructs Claude to act as a security monitor that evaluates autonomous coding agent actions against block/allow rules to prevent prompt injection, scope creep, and accidental damage.
* Agent Prompt: Security monitor for autonomous agent actions (second part) (**5500** tks) - Defines the environment context, block rules, and allow exceptions that govern which tool actions the agent may or may not perform.
* Agent Prompt: Session search (**158** tks) - Subagent prompt for searching past Claude Code conversation sessions by scanning .jsonl transcript files and returning matching session IDs.
* Agent Prompt: Session title and branch generation (**307** tks) - Agent for generating succinct session titles and git branch names.
* Agent Prompt: Session transcript chunk summary (**89** tks) - Instructs an agent to summarize a chunk of a Claude Code session transcript concisely.
* Agent Prompt: Summarization no-tools guard (**107** tks) - Shared prefix for compaction summarization agents that forbids tool use and requires plain text analysis and summary blocks.
* Agent Prompt: WebFetch summarizer (**189** tks) - Prompt for agent that summarizes verbose output from WebFetch for the main model.
* Agent Prompt: Worker fork (**268** tks) - System prompt for a forked worker sub-agent that executes a single directive from the parent agent and reports back concisely.
* Agent Prompt: Workflow script plain text return note (**76** tks) - Appended note telling a workflow script agent that its final text response is parsed as the script return value.
* Agent Prompt: Workflow script structured return note (**120** tks) - Appended note telling a workflow script agent to return its final answer by calling the structured output tool exactly once.
* Agent Prompt: Workflow subagent plain text output (**154** tks) - Instructs an internal workflow subagent to return its final text verbatim as the calling workflow script's parsed result.
* Agent Prompt: Workflow subagent structured output (**190** tks) - Instructs an internal workflow subagent to return its final answer by calling the StructuredOutput tool exactly once with schema-valid input.

### Data

The content of various template files embedded in Claude Code.

* Data: Anthropic CLI (**4615** tks) - Reference documentation for the ant CLI covering installation, authentication, command structure, input and output shaping, managed agents workflows, and scripting patterns.
* Data: Assistant voice and values template (**454** tks) - Template content for an assistant.md file describing Claude's voice, values, and communication style.
* Data: Claude API reference — C# (**5071** tks) - C# SDK reference including installation, client initialization, basic requests, streaming, and tool use.
* Data: Claude API reference — Go (**4898** tks) - Go SDK reference.
* Data: Claude API reference — Java (**4912** tks) - Java SDK reference including installation, client initialization, basic requests, streaming, and beta tool use.
* Data: Claude API reference — PHP (**3943** tks) - PHP SDK reference.
* Data: Claude API reference — Python (**5524** tks) - Python SDK reference including installation, client initialization, basic requests, thinking, and multi-turn conversation.
* Data: Claude API reference — Ruby (**1301** tks) - Ruby SDK reference including installation, client initialization, basic requests, streaming, and beta tool runner.
* Data: Claude API reference — TypeScript (**4116** tks) - TypeScript SDK reference including installation, client initialization, basic requests, thinking, and multi-turn conversation.
* Data: Claude API reference — cURL (**2890** tks) - Raw API reference for Claude API for use with cURL or else Raw HTTP.
* Data: Claude Code live documentation sources (**1380** tks) - WebFetch URLs for fetching current Claude Code documentation from official sources.
* Data: Claude Code recent changes reference (**528** tks) - Reference mapping of recently removed or renamed Claude Code commands, flags, and terms to their current replacements.
* Data: Claude Platform on AWS reference (**1158** tks) - Reference documentation for using the Claude Developer Platform through AWS infrastructure, including AnthropicAWS clients, required region and workspace configuration, SigV4 authentication, and short-term API keys.
* Data: Claude model catalog (**3079** tks) - Catalog of current and legacy Claude models with exact model IDs, aliases, context windows, and pricing.
* Data: Cowork plugin MCP discovery and connection (**1338** tks) - Reference guidance for finding MCP connectors during plugin customization, using search and suggestion tools, mapping categories to keywords, and writing .mcp.json entries.
* Data: Cowork plugin component schemas (**3109** tks) - Reference documentation for Cowork plugin component formats, including skills, agents, hooks, MCP servers, legacy commands, CONNECTORS.md, and README.md.
* Data: Cowork plugin examples (**2323** tks) - Reference examples of minimal, medium, and complex Cowork plugin structures with plugin metadata, skills, agents, hooks, MCP config, README, and connectors.
* Data: Files API reference — Python (**1360** tks) - Python Files API reference including file upload, listing, deletion, and usage in messages.
* Data: Files API reference — TypeScript (**797** tks) - TypeScript Files API reference including file upload, listing, deletion, and usage in messages.
* Data: GitHub Actions workflow for @claude mentions (**525** tks) - GitHub Actions workflow template for triggering Claude Code via @claude mentions.
* Data: GitHub App installation PR description (**409** tks) - Template for PR description when installing Claude Code GitHub App integration.
* Data: HTTP error codes reference (**2755** tks) - Reference for HTTP error codes returned by the Claude API with common causes and handling strategies.
* Data: Knowledge MCP search strategies (**447** tks) - Reference query patterns for using knowledge MCPs to discover organization-specific tool names, project identifiers, team names, and workflow details during plugin customization.
* Data: Live documentation sources (**4316** tks) - WebFetch URLs for fetching current Claude API and Agent SDK documentation from official sources.
* Data: Managed Agents client patterns (**2754** tks) - Reference guide of common client-side patterns for driving Managed Agent sessions, including stream reconnection, idle-break gating, tool confirmations, interrupts, and custom tools.
* Data: Managed Agents core concepts (**4000** tks) - Reference documentation for the Managed Agents API covering core concepts (Agents, Sessions, Environments, Containers), lifecycle, versioning, endpoints, and usage patterns.
* Data: Managed Agents endpoint reference (**7765** tks) - Comprehensive reference for Managed Agents API endpoints, SDK methods, request/response schemas, error handling, and rate limits.
* Data: Managed Agents environments and resources (**3191** tks) - Reference documentation covering Managed Agents environments, file resources, GitHub repository mounting, and the Files API with SDK examples.
* Data: Managed Agents events and steering (**3056** tks) - Reference guide for sending and receiving events on managed agent sessions, including streaming, polling, reconnection, message queuing, interrupts, and event payload details.
* Data: Managed Agents memory stores reference (**2780** tks) - Reference documentation for Managed Agents memory stores, including store creation, session attachment, FUSE mounts, memory CRUD, concurrency, versions, redaction, and endpoint paths.
* Data: Managed Agents multiagent sessions (**1839** tks) - Reference documentation for Managed Agents multiagent sessions, including coordinator rosters, threads, session stream events, subagent tool permissions, and pitfalls.
* Data: Managed Agents outcomes (**1772** tks) - Reference documentation for Managed Agents outcomes, including user.define\_outcome events, rubrics, outcome evaluation events, deliverables, and interaction rules.
* Data: Managed Agents overview (**2941** tks) - Provides the agent with a comprehensive overview of the Managed Agents API architecture, mandatory agent-then-session flow, beta headers, documentation reading guide, and common pitfalls.
* Data: Managed Agents reference — Python (**2893** tks) - Reference guide for using the Anthropic Python SDK to create and manage agents, sessions, environments, streaming, custom tools, files, and MCP servers.
* Data: Managed Agents reference — TypeScript (**2875** tks) - Reference guide for using the Anthropic TypeScript SDK to create and manage agents, sessions, environments, streaming, custom tools, file uploads, and MCP server integration.
* Data: Managed Agents reference — cURL (**2658** tks) - Provides cURL and raw HTTP request examples for the Managed Agents API including environment, agent, and session lifecycle operations.
* Data: Managed Agents scheduled deployments (**1992** tks) - Reference documentation for Managed Agents scheduled deployments, including cron schedule creation, deployment runs, lifecycle operations, failure behavior, and manual runs.
* Data: Managed Agents self-hosted sandboxes (**2930** tks) - Reference documentation for running Managed Agents tool execution in self-hosted infrastructure, including environment setup, workers, webhook-driven wake, orchestration, monitoring, credentials, and security responsibilities.
* Data: Managed Agents tools and skills (**4953** tks) - Reference documentation covering the Managed Agents SDK's tool types (agent toolset, MCP, custom), permission policies, vault credential management, and skills API for building specialized agents.
* Data: Managed Agents webhooks (**1439** tks) - Reference documentation for Managed Agents webhooks, including endpoint registration, signature verification, payload envelopes, supported event types, delivery behavior, and pitfalls.
* Data: Message Batches API reference — Python (**1635** tks) - Python Batches API reference including batch creation, status polling, and result retrieval at 50% cost.
* Data: Message Batches API — TypeScript (**805** tks) - TypeScript usage guide for Claude's asynchronous Message Batches endpoint.
* Data: Prompt Caching — Design & Optimization (**3927** tks) - Document on how to design prompt-building code for effective caching, including placement patterns and anti-patterns.
* Data: Streaming reference — Python (**1725** tks) - Python streaming reference including sync/async streaming and handling different content types.
* Data: Streaming reference — TypeScript (**1675** tks) - TypeScript streaming reference including basic streaming and handling different content types.
* Data: Token counting reference (**486** tks) - Reference documentation for counting Claude model tokens with the Messages count\_tokens endpoint and Anthropic SDK or CLI examples, including warnings against OpenAI tokenizers.
* Data: Tool use concepts (**4446** tks) - Conceptual foundations of tool use with the Claude API including tool definitions, tool choice, and best practices.
* Data: Tool use reference — Python (**5106** tks) - Python tool use reference including tool runner, manual agentic loop, code execution, and structured outputs.
* Data: Tool use reference — TypeScript (**5033** tks) - TypeScript tool use reference including tool runner, manual agentic loop, code execution, and structured outputs.
* Data: User profile memory template (**232** tks) - Template content for the user profile memory file, covering personal details, work context, schedule, and communication preferences.

### System Prompt

Parts of the main system prompt.

* System Prompt: /loop tick (loop.md absent, dynamic pacing) (**177** tks) - Loop tick injection for dynamic self-paced autonomous checks when loop.md is absent.
* System Prompt: /loop tick (loop.md tasks) (**94** tks) - Loop tick injection for recurring cron-based runs of tasks from loop.md.
* System Prompt: /loop tick (loop.md tasks, dynamic pacing) (**174** tks) - Loop tick injection for dynamic self-paced runs of tasks from loop.md.
* System Prompt: Act when ready (**68** tks) - Instructs the agent to act once it has enough information and give recommendations instead of exhaustive surveys.
* System Prompt: Action safety and truthful reporting (**190** tks) - Requires confirmation for irreversible or outward-facing actions, checking targets before destructive edits, and truthful reporting of outcomes.
* System Prompt: Advisor tool instructions (**443** tks) - Instructions for using the Advisor tool.
* System Prompt: Agent Summary Generation (**178** tks) - System prompt used for "Agent Summary" generation.
* System Prompt: Agent memory instructions (**337** tks) - Instructions for including memory update guidance in agent system prompts.
* System Prompt: Agent thread notes (**205** tks) - Behavioral guidelines for agent threads covering absolute paths, response formatting, emoji avoidance, and tool call punctuation.
* System Prompt: Auto mode (**244** tks) - Continuous task execution, akin to a background agent.
* System Prompt: Autonomous loop check (**1071** tks) - Defines behavior for autonomous timer-based invocations, guiding Claude to continue established work, maintain PRs, and handle repeated idle checks while the user is away.
* System Prompt: Autonomous loop notification guidance (**98** tks) - Guides when autonomous loop ticks should notify the user via PushNotification for blockers or actionable state changes.
* System Prompt: Autonomous loop persistence guidance (CLAUDE\_CODE\_LOOP\_PERSISTENT) (**1173** tks) - Defines behavior for autonomous timer-based invocations, guiding Claude to persistently continue established work, maintain PRs, and broaden scope before stopping while the user is away.
* System Prompt: Autonomous loop tick (dynamic pacing) (**168** tks) - Autonomous loop tick injection for dynamic self-paced autonomous checks scheduled with ScheduleWakeup.
* System Prompt: Autonomous loop tick (**87** tks) - Autonomous loop tick injection for recurring cron-based autonomous checks.
* System Prompt: Autonomous operation guidelines (**301** tks) - Instructs autonomous sessions to proceed on reversible work, stop for destructive or scope-changing actions, and finish promised work before ending the turn.
* System Prompt: Avoiding Unnecessary Sleep Commands (part of PowerShell tool description) (**175** tks) - Guidelines for avoiding unnecessary sleep commands in PowerShell scripts, including alternatives for waiting and notification.
* System Prompt: Background session instructions (**153** tks) - Instructions for background job sessions to use the job-specific temporary directory and follow the appropriate worktree isolation guidance.
* System Prompt: Background worktree isolation guidance (**129** tks) - Tells background sessions when to enter an isolated worktree before making code changes and when to continue in place.
* System Prompt: Censoring assistance with malicious activities (**98** tks) - Guidelines for assisting with authorized security testing, defensive security, CTF challenges, and educational contexts while censoring requests for malicious activities.
* System Prompt: Chrome browser MCP tools (**255** tks) - Instructions for loading deferred Chrome browser MCP tools through ToolSearch in a single batched selection before browser tasks.
* System Prompt: Clarifying question research first (**88** tks) - Encourages brief read-only investigation before asking the user clarifying questions.
* System Prompt: Claude Fable 5 model identity (**177** tks) - Identifies this Claude iteration as Claude Fable 5, explains its relationship to Claude Mythos 5, and points users to Anthropic's Fable and Mythos announcement for differences.
* System Prompt: Claude in Chrome browser automation (**962** tks) - Instructions for using Claude in Chrome browser automation tools effectively.
* System Prompt: Claude in Chrome browser selection instructions (**137** tks) - Instructs the agent to ask the user to choose among multiple connected Chrome browsers before using browser automation tools.
* System Prompt: Combined memory index pointer instructions (**120** tks) - Instructs the agent to add one-line pointers for private and team memories to the single private memory index and never write memory content there.
* System Prompt: Comment what and task context avoidance (**76** tks) - Instructs Claude not to write comments that explain what code does or reference transient task context.
* System Prompt: Comment why-only guidance (**67** tks) - Instructs Claude to write code comments only when the reason is non-obvious and useful to future readers.
* System Prompt: Communication style (**297** tks) - Instructs Claude to give brief, user-facing updates at key moments during tool use, write concise end-of-turn summaries, match response format to task complexity, and avoid comments and planning documents in code.
* System Prompt: Context compaction summary (**278** tks) - Prompt used for context compaction summary (for the SDK).
* System Prompt: Coordinator mode orchestration (**3562** tks) - Provides coordinator-mode instructions for delegating work to worker agents, managing worker lifecycle, handling cross-session peers, and verifying delegated results.
* System Prompt: Coordinator worker instructions (**496** tks) - Instructions for worker agents executing coordinator-assigned tasks, covering scope control, concurrent branch changes, resumption, failure handling, and coordinator-facing output.
* System Prompt: Current Claude models (**131** tks) - Lists the current Claude model family IDs and recommends using the latest capable models for AI applications.
* System Prompt: Deny rule circumvention classifier guidance (**74** tks) - Guides permission classification to block attempts to route around configured Edit, Write, or MultiEdit deny rules.
* System Prompt: Description part of memory instructions (**148** tks) - Field for describing _what_ the memory is. Part of a bigger effort to instruct Claude how to create memories.
* System Prompt: Doing tasks (ambitious tasks) (**47** tks) - Allow users to complete ambitious tasks; defer to user judgement on scope.
* System Prompt: Doing tasks (help and feedback) (**24** tks) - How to inform users about help and feedback channels.
* System Prompt: Doing tasks (no compatibility hacks) (**52** tks) - Delete unused code completely rather than adding compatibility shims.
* System Prompt: Doing tasks (no unnecessary additions) (**73** tks) - Do not add features, refactor, or improve beyond what was asked.
* System Prompt: Doing tasks (no unnecessary error handling) (**64** tks) - Do not add error handling for impossible scenarios; only validate at boundaries.
* System Prompt: Doing tasks (security) (**67** tks) - Avoid introducing security vulnerabilities like injection, XSS, etc.
* System Prompt: Doing tasks (software engineering focus) (**104** tks) - Users primarily request software engineering tasks; interpret instructions in that context.
* System Prompt: Dream CLAUDE.md memory reconciliation (**279** tks) - Instructs dream memory consolidation to reconcile feedback and project memories against CLAUDE.md, deleting stale memories or flagging possible CLAUDE.md drift.
* System Prompt: Dream team memory handling (**279** tks) - Instructions for handling shared team memories during dream consolidation, including deduplication, conservative pruning rules, and avoiding accidental promotion of personal memories.
* System Prompt: Emoji avoidance (**31** tks) - Instructs Claude to avoid using emojis unless the user explicitly asks for them.
* System Prompt: Executing actions with care (fragment) (**85** tks) - Brief form of the 'executing actions with care' guidance separating safe investigation from hard-to-reverse actions.
* System Prompt: Executing actions with care (**590** tks) - Instructions for executing actions carefully.
* System Prompt: Explain /code-review ultra (**131** tks) - Guidance shown when a user asks about 'ultrareview': explains it maps to /code-review ultra (the /ultrareview alias is deprecated) and that the agent can't start it directly.
* System Prompt: Exploratory questions — analyze before implementing (**75** tks) - Instructs Claude to respond to open-ended questions with analysis, options, and tradeoffs instead of jumping to implementation, waiting for user agreement before writing code.
* System Prompt: Feedback memory body structure (**79** tks) - Defines the body structure for feedback memories, including the rule, why, and how to apply it.
* System Prompt: Feedback memory save guidance (**121** tks) - Explains when to save feedback memories from user corrections or confirmed non-obvious approaches.
* System Prompt: Focus mode (long form) (**105** tks) - Focus-mode notice (long form): the user sees only the final text, not tool calls, results, or inter-step writing.
* System Prompt: Focus mode (short form) (**91** tks) - Focus-mode notice (short form): only each response's final text reaches the user.
* System Prompt: Fork usage guidelines (**326** tks) - Instructions for when to fork subagents and rules against reading fork output mid-flight or fabricating fork results.
* System Prompt: Forked agent guidance (**131** tks) - Explains that calling Agent with subagent\_type "fork" creates a background fork and when to use it.
* System Prompt: Frontend browser verification (**86** tks) - Requires Claude to start the dev server and verify UI or frontend changes in a browser before reporting completion.
* System Prompt: Git status (**37** tks) - System prompt for displaying the current git status at the start of the conversation.
* System Prompt: Harness instructions (**178** tks) - Core interactive-agent identity and harness instructions for terminal markdown output, permissions, system reminders, compaction, tool use, and code references.
* System Prompt: Hook evaluator truncated transcript note (**74** tks) - Tells the hook condition evaluator that earlier conversation was omitted and how to handle insufficient evidence.
* System Prompt: Hook feedback handling (**85** tks) - Explains that hook feedback should be treated as user feedback and how to respond when hooks block actions.
* System Prompt: Hooks Configuration (**1493** tks) - System prompt for hooks configuration. Used for above Claude Code config skill.
* System Prompt: How to use the SendUserMessage tool (**283** tks) - Instructions for using the SendUserMessage tool.
* System Prompt: Insights at a glance summary (**569** tks) - Generates a concise 4-part summary (what's working, hindrances, quick wins, ambitious workflows) for the insights report.
* System Prompt: Insights friction analysis (**139** tks) - Analyzes aggregated usage data to identify friction patterns and categorize recurring issues.
* System Prompt: Insights interaction style (**119** tks) - Analyzes Claude Code usage data to describe the user's interaction style.
* System Prompt: Insights memorable moment (**96** tks) - Analyzes Claude Code usage data to find a memorable qualitative moment.
* System Prompt: Insights on the horizon (**148** tks) - Identifies ambitious future workflows and opportunities for autonomous AI-assisted development.
* System Prompt: Insights session facets extraction (**310** tks) - Extracts structured facets (goal categories, satisfaction, friction) from a single Claude Code session transcript.
* System Prompt: Insights suggestions (**737** tks) - Generates actionable suggestions including CLAUDE.md additions, features to try, and usage patterns.
* System Prompt: Insights summary (At a Glance) (**194** tks) - The 'At a Glance' summary block of the Insights report (what's working / what's hindering).
* System Prompt: Insights what works (**121** tks) - Analyzes Claude Code usage data to identify workflows that are working well for the user.
* System Prompt: Interactive agent intro (output-style active) (**34** tks) - Opening system-prompt line for sessions that have an Output Style configured.
* System Prompt: Interactive agent intro (output-style conditional) (**125** tks) - Opening system-prompt line that branches on whether an Output Style is configured.
* System Prompt: Interactive agent intro (short) (**20** tks) - Minimal opening system-prompt line for software-engineering sessions.
* System Prompt: Learning mode (insights) (**142** tks) - Instructions for providing educational insights when learning mode is active.
* System Prompt: Learning mode (**1042** tks) - Main system prompt for learning mode with human collaboration instructions.
* System Prompt: Memory description of user details (**122** tks) - Describes the purpose and guidelines for per-user memory files that accumulate details about the user's role, goals, knowledge, and preferences across sessions.
* System Prompt: Memory description of user feedback (with explicit save) (**146** tks) - Describes the feedback memory type that captures user guidance on work approaches, emphasizing recording both successes and failures and explicitly instructing to save a new memory noting contradictions with team feedback.
* System Prompt: Memory description of user feedback (**139** tks) - Describes the user feedback memory type that stores guidance about work approaches, emphasizing recording both successes and failures and checking for contradictions with team memories.
* System Prompt: Memory file granularity (**73** tks) - Instructs the agent to keep each memory file to one paragraph about a single durable fact and split multiple facts into separate files.
* System Prompt: Memory file immutability (**67** tks) - Instructs the agent not to edit memory files in place, but to replace stale or invalid files carefully.
* System Prompt: Memory index pointer instructions (**90** tks) - Instructs the agent to add one-line pointers to the memory index file and treat the index as separate from memory content.
* System Prompt: Memory instructions (**391** tks) - Instructions for using persistent file-based memory, including memory file format, scope, indexing, and stale-memory handling.
* System Prompt: Memory persistence scope (**60** tks) - Explains that memory is for information useful in future conversations, not only within the current conversation.
* System Prompt: Memory save exclusions (**14** tks) - Lists categories of information that should not be saved in memory, even when the user asks.
* System Prompt: Memory staleness verification (**112** tks) - Instructs the agent to verify memory records against current file/resource state and delete stale memories that conflict with observed reality.
* System Prompt: Minimal mode (**164** tks) - Describes the behavior and constraints of minimal mode, which skips hooks, LSP, plugins, auto-memory, and other features while requiring explicit context via CLI flags.
* System Prompt: Monitor fallback heartbeat guidance (**142** tks) - Guides dynamic loop ticks to use Monitor as the primary wake signal, ScheduleWakeup as a fallback heartbeat, and stop the monitor when ending the loop.
* System Prompt: One of six rules for using sleep command (**23** tks) - One of the six rules for using the sleep command.
* System Prompt: Option previewer (**151** tks) - System prompt for previewing UI options in a side-by-side layout.
* System Prompt: Outcome-first communication style (**599** tks) - Instructs Claude to keep user-facing updates readable and outcome-first, answer directly after work completes, match response format to task complexity, and limit code comments to non-obvious constraints.
* System Prompt: PR Slack notification step (**125** tks) - Adds a PR workflow step to optionally ask the user before posting the PR URL to Slack.
* System Prompt: Parallel tool call note (part of "Tool usage policy") (**102** tks) - System prompt for telling Claude to using parallel tool calls.
* System Prompt: Partial compaction instructions (**805** tks) - Instructions on how to compact when the user decided to compact only a portion of the conversation, with a structured summary format and analysis process.
* System Prompt: Permission classifier strict review guidance (**79** tks) - Instructs the permission classifier to carefully deny blocked actions and require explicit user confirmation for overrides.
* System Prompt: Personal project memory description (**67** tks) - Describes project memories for ongoing work, goals, initiatives, bugs, or incidents relevant to the user's work in a directory.
* System Prompt: Phase four of plan mode (**187** tks) - Phase four of plan mode.
* System Prompt: Plan sent to Ultraplan (**106** tks) - User-facing note confirming a plan has been sent to Ultraplan for remote refinement.
* System Prompt: Plan vs memory guidance (**87** tks) - Explains when to use or update a plan instead of saving information to memory.
* System Prompt: PowerShell edition for 5.1 (**285** tks) - System prompt for providing information about Windows PowerShell 5.1.
* System Prompt: PowerShell edition for 7+ (**128** tks) - Describes PowerShell 7+ shell syntax support, including pipeline chain operators, ternary, null-coalescing, and UTF-8 defaults.
* System Prompt: PowerShell edition unknown (**108** tks) - Assumes Windows PowerShell 5.1 compatibility when the PowerShell edition is unknown and forbids PowerShell 7-only syntax.
* System Prompt: Prefer editing existing files (**17** tks) - Instructs Claude to prefer editing existing files instead of creating new ones.
* System Prompt: Proactive schedule offer after natural future follow-up (**338** tks) - Instructs the agent to offer a one-line /schedule follow-up after completed work when there is a likely one-time or recurring future action.
* System Prompt: Project memory body structure (**83** tks) - Defines the body structure for project memories, including the fact or decision, why, and how to apply it.
* System Prompt: Project memory save guidance (stale refresh) (**99** tks) - Explains when to save project memories and to replace stale project memories with fresh ones while converting relative dates to absolute dates.
* System Prompt: Project memory save guidance (**91** tks) - Explains when to save project memories about who is doing what, why, or by when, including absolute date handling.
* System Prompt: REPL tool usage and scripting conventions (**1049** tks) - Instructs Claude on how to use the REPL tool effectively with dense JavaScript scripts, shorthands, batching rules, and API reference for investigation tasks.
* System Prompt: Recalled memories in tool results (**67** tks) - Explains how to treat automatically recalled memory system-reminder blocks in tool results as background context rather than direct user instructions.
* System Prompt: Remote plan mode (ultraplan) (**617** tks) - System reminder injected during remote planning sessions that instructs Claude to explore the codebase, produce a diagram-rich plan via ExitPlanMode, and implement it with a pull request upon approval.
* System Prompt: Remote planning session (**432** tks) - System reminder that configures a remote planning session to explore the codebase, produce an implementation plan via ExitPlanMode, and handle plan approval, rejection, or teleportation back to the user's local terminal.
* System Prompt: Respond in configured language (**128** tks) - Directs all responses, explanations, and code commentary into a configured language.
* System Prompt: Scratchpad directory (**0** tks) - Instructions for using a dedicated scratchpad directory for temporary files.
* System Prompt: Skillify Current Session (**1798** tks) - System prompt for converting the current session in to a skill.
* System Prompt: Strict proactive schedule offer gate (**221** tks) - Restricts proactive /schedule offers to completed work with a named future obligation artifact, concrete timing, and no in-session follow-up available.
* System Prompt: Subagent delegation examples (**620** tks) - Provides example interactions showing how a coordinator agent should delegate tasks to subagents, handle waiting states, and report results.
* System Prompt: Subagent prompt-writing examples (**439** tks) - Provides example usage patterns demonstrating how to write self-contained, well-structured prompts when delegating tasks to subagents.
* System Prompt: System section (**93** tks) - System section of the main system prompt.
* System Prompt: Task approval continuity (**109** tks) - Instructs the agent to continue agreed tasks end to end without unnecessary re-confirmation.
* System Prompt: Tasks vs memory guidance (**80** tks) - Explains when to use tasks instead of saving current-conversation progress to memory.
* System Prompt: Team memory index pointer instructions (**107** tks) - Instructs the agent to add one-line memory pointers to the appropriate team memory index file and never write memory content into the index.
* System Prompt: Team project memory description (**67** tks) - Describes project memories for shared ongoing work, goals, initiatives, bugs, or incidents within a working directory.
* System Prompt: Teammate Communication (**105** tks) - System prompt for teammate communication in swarm.
* System Prompt: Tone and style (code references) (**39** tks) - Instruction to include file\_path:line\_number when referencing code.
* System Prompt: Tone and style (concise output — short) (**16** tks) - Instruction for short and concise responses.
* System Prompt: Tool call colon avoidance (**59** tks) - Instructs Claude not to use a colon before tool calls because tool calls may be hidden from user output.
* System Prompt: Tool call summary label (**112** tks) - Instructs Claude to write a short past-tense summary label for completed tool calls in mobile UI rows.
* System Prompt: Tool execution denied (**144** tks) - System prompt for when tool execution is denied.
* System Prompt: Tool usage (subagent guidance) (**103** tks) - Guidance on when and how to use subagents effectively.
* System Prompt: Tool usage (task management) (**70** tks) - Use TodoWrite to break down and track work progress.
* System Prompt: Troubleshooting confirmation policy (**71** tks) - Requires explaining fixes and confirming before destructive or installation-changing troubleshooting commands.
* System Prompt: User memory usage guidance (**91** tks) - Explains when to use user memories to tailor responses to the user's profile or perspective.
* System Prompt: WSL managed settings double opt-in (**152** tks) - Explains that WSL can read the Windows managed settings policy chain only when the admin-enabled flag is set, with HKCU requiring an additional user opt-in.
* System Prompt: Worker instructions (**272** tks) - Instructions for workers to follow when implementing a change.
* System Prompt: Writing subagent prompts (**275** tks) - Guidelines for writing effective prompts when delegating tasks to subagents, covering context-inheriting vs fresh subagent scenarios.

### System Reminders

Text for large system reminders.

* System Reminder: /btw side question (**244** tks) - System reminder for /btw slash command side questions without tools.
* System Reminder: Agent mention (**45** tks) - Notification that user wants to invoke an agent.
* System Reminder: App read-only access guidance (**93** tks) - Warns that read-tier non-browser apps are screenshot-only and asks the user to perform interactions themselves.
* System Reminder: Async agent launched (**124** tks) - Warns Claude not to duplicate an asynchronously launched agent's work or read its full JSONL transcript output file.
* System Reminder: Auto mode clarification bias (**124** tks) - Encourages auto mode to make reasonable decisions without stopping for clarification unless the task requires it.
* System Reminder: Brief mode toggle (**107** tks) - Announces whether brief mode is enabled and whether user-facing output must use the SendUserMessage tool.
* System Reminder: Brief mode user-facing output (**97** tks) - Reminds Claude that plain assistant text is hidden in brief mode and user-facing output must be sent through SendUserMessage.
* System Reminder: Browser extension not connected (**102** tks) - Tells the user how to resolve a disconnected Claude browser extension and where to report bugs.
* System Reminder: Browser read-only access guidance (**99** tks) - Warns that read-tier browser apps are screenshot-only and directs browser interaction to the Claude-in-Chrome MCP tools.
* System Reminder: Compact file reference (**57** tks) - Reference to file read before conversation summarization.
* System Reminder: Computer use policy-blocked apps (**142** tks) - Warns that listed apps are blocked by computer-use policy, cannot be overridden in Settings, and must not be accessed.
* System Reminder: Coordinator message (**73** tks) - Relays a coordinator message while warning that it is not user input or user confirmation.
* System Reminder: Cross-session peer message authority warning (**126** tks) - Warns that an incoming message from another Claude session is not user authority, cannot grant consent, and must not be used for permission laundering.
* System Reminder: Cross-session peer message wrapper (**158** tks) - Wraps an incoming cross-session peer message with a header, the message content, an authority warning, and an optional response note.
* System Reminder: Deferred tools available (**101** tks) - Announces newly available deferred tools and instructs the agent to load their schemas through ToolSearch.
* System Reminder: Exited plan mode (**41** tks) - Notification when exiting plan mode.
* System Reminder: External source trust boundary (**108** tks) - Warns that an external plugin or channel message is not from the user and must be treated as untrusted data rather than instructions.
* System Reminder: File exists but empty (**27** tks) - Warning when reading an empty file.
* System Reminder: File modification detected (budget exceeded) (**104** tks) - System reminder for when a file modification is detected - specifically when other modified files in the turn already exceeded the budget.
* System Reminder: File modified by user or linter (**97** tks) - Notification that a file was modified externally.
* System Reminder: File opened in IDE (**37** tks) - Notification that user opened a file in IDE.
* System Reminder: File shorter than offset (**59** tks) - Warning when file read offset exceeds file length.
* System Reminder: File summary completeness disclosure (**107** tks) - Requires Claude to disclose how much file content was read before summarizing and to stop retrying after repeated read failures.
* System Reminder: File truncated (**74** tks) - Notification that file was truncated due to size.
* System Reminder: Hook additional context (**35** tks) - Additional context from a hook.
* System Reminder: Hook blocking error (**52** tks) - Error from a blocking hook command.
* System Reminder: Hook stopped continuation prefix (**12** tks) - Prefix for hook stopped continuation messages.
* System Reminder: Hook stopped continuation (**30** tks) - Message when a hook stops continuation.
* System Reminder: Hook success (**29** tks) - Success message from a hook.
* System Reminder: Large PDF read guidance (**147** tks) - Warns that a PDF is too large to read at once and requires reading specific page ranges.
* System Reminder: Large file full-content reading guidance (**117** tks) - Advises how to read full large-file content for analysis, preferably inside a subagent when the Agent tool is available.
* System Reminder: Lines selected in IDE (**66** tks) - Notification about lines selected by user in IDE.
* System Reminder: MCP output truncation warning (**86** tks) - Warns that MCP tool output exceeded the token limit and advises pagination, filtering, or noting incomplete results.
* System Reminder: MCP resource no content (**41** tks) - Shown when MCP resource has no content.
* System Reminder: MCP resource no displayable content (**43** tks) - Shown when MCP resource has no displayable content.
* System Reminder: MCP servers connecting (**128** tks) - Lists MCP servers that are still connecting and tells the agent to search their tools before reporting a capability unavailable.
* System Reminder: Memory consolidation tool constraints (immutable) (**116** tks) - Restricts the memory consolidation job to read-only shell access plus deleting and rewriting immutable memory files.
* System Reminder: Memory consolidation tool constraints (**147** tks) - Restricts the memory consolidation job to read-only shell access plus deleting memory files and lists sessions to review.
* System Reminder: Memory extraction recent context only (**65** tks) - Restricts the memory extraction subagent to saving facts from only the recent conversation window.
* System Reminder: Memory extraction tool constraints (immutable) (**166** tks) - Lists the tools available to the memory extraction subagent when memory files are immutable.
* System Reminder: Memory extraction tool constraints (**143** tks) - Lists the tools available to the memory extraction subagent for reading and updating memory files.
* System Reminder: Memory extraction turn budget (immutable) (**59** tks) - Instructs the memory extraction subagent to batch memory writes and deletes when memory files are immutable.
* System Reminder: Memory extraction turn budget (**111** tks) - Instructs the memory extraction subagent to batch memory reads before issuing memory edits and writes.
* System Reminder: Memory file contents (**36** tks) - Contents of a memory file by path.
* System Reminder: Nested memory contents (**33** tks) - Contents of a nested memory file.
* System Reminder: New diagnostics detected (**52** tks) - Notification about new diagnostic issues.
* System Reminder: Output style active (**50** tks) - Notification that an output style is active.
* System Reminder: Plan approved (**100** tks) - Notifies Claude that the user approved the plan, provides the saved plan file and approved plan content, and allows coding to begin.
* System Reminder: Plan awaiting team-lead approval (**116** tks) - Reminder laying out what happens after a plan is submitted for team-lead approval.
* System Reminder: Plan file reference (**62** tks) - Reference to an existing plan file.
* System Reminder: Plan mode approval tool enforcement (**236** tks) - Requires plan mode turns to end with either AskUserQuestion for clarification or ExitPlanMode for plan approval, and forbids asking for approval any other way.
* System Reminder: Plan mode is active (5-phase) (**927** tks) - Enhanced plan mode system reminder with parallel exploration and multi-agent planning.
* System Reminder: Plan mode is active (subagent) (**307** tks) - Simplified plan mode system reminder for sub agents.
* System Reminder: Plan mode is active (**147** tks) - Reminds Claude that plan mode is active, clarifications should use AskUserQuestion, plans should use ExitPlanMode, and edits are not allowed.
* System Reminder: Plan mode re-entry (**236** tks) - System reminder sent when the user enters Plan mode after having previously exited it either via shift+tab or by approving Claude's plan.
* System Reminder: Previously invoked skills (**131** tks) - Restores skills invoked before conversation compaction as context only, warning not to re-execute their setup actions or treat prior inputs as current instructions.
* System Reminder: Provider context (**75** tks) - Warns that the session is not using Anthropic's first-party API and that some features may differ.
* System Reminder: Question context (**137** tks) - Provides potentially relevant context entries to use only when highly relevant to the current task.
* System Reminder: Read truncation retry guidance (**80** tks) - Instructs Claude to reduce chunk size after file-read truncation warnings and notes the Bash output character limit.
* System Reminder: Session continuation (**37** tks) - Notification that session continues from another machine.
* System Reminder: Session stop hook active (**111** tks) - Tells Claude a session-scoped Stop hook condition is active and must be treated as the directive until met.
* System Reminder: Stop hook blocking error (**20** tks) - Error from a blocking hook command.
* System Reminder: Task tools reminder (**111** tks) - Reminder to use task tracking tools.
* System Reminder: Team Coordination (**0** tks) - System reminder for team coordination.
* System Reminder: Team Shutdown (**136** tks) - System reminder for team shutdown.
* System Reminder: Terminal and IDE click-tier restrictions (**128** tks) - Explains click-tier limits for terminal and IDE apps, including no keyboard input, context-menu paste, or drag-drop.
* System Reminder: TodoWrite reminder (**86** tks) - Reminder to use TodoWrite tool for task tracking.
* System Reminder: Token usage (**39** tks) - Current token usage statistics.
* System Reminder: USD budget (**42** tks) - Current USD budget statistics.
* System Reminder: Ultracode enabled (**74** tks) - Instructs the agent to optimize for exhaustive correctness and use Workflow on substantive tasks when Ultracode is enabled.
* System Reminder: Ultraplan mode (**437** tks) - System reminder for using Ultraplan mode to create a detailed implementation plan with multi-agent exploration and critique.
* System Reminder: Verify plan reminder (**47** tks) - Reminder to verify completed plan.
* System Reminder: Workflow isolated worktree (**111** tks) - Tells a workflow subagent it is running in an isolated git worktree separate from the main working directory.

### Builtin Tool Descriptions

* Tool Description: Agent explicit-spawn restriction (**0** tks) - Restricts agent spawning to explicit user requests or named agent types instead of inferred thoroughness.
* Tool Description: ArtifactTool (**36** tks) - ArtifactTool: publishes an HTML or Markdown file as a claude.ai web page, private by default.
* Tool Description: Artifact (**0** tks) - Describes the Artifact tool for deploying self-contained HTML or Markdown pages, including file-first usage, update behavior, CSP constraints, responsive design, and favicon requirements.
* Tool Description: AskUserQuestion decision guidance (**60** tks) - Additional guidance for using AskUserQuestion only when the user's answer changes what the agent should do next.
* Tool Description: AskUserQuestion (**220** tks) - Tool description for asking user questions.
* Tool Description: Browser file upload (**130** tks) - Describes the browser file upload tool, which uploads shared files directly to a page file input by element ref and enforces the 10 MB combined size limit.
* Tool Description: BrowserBatch (**159** tks) - Tool description for BrowserBatch, which executes multiple browser tool calls sequentially in one round trip.
* Tool Description: Chrome browser automation (**62** tks) - Describes Chrome browser automation tools for page interaction, screenshots, console logs, and navigation.
* Tool Description: Claude in Chrome JavaScript tool (**75** tks) - Describes the Claude in Chrome JavaScript execution tool for running code in the current page context.
* Tool Description: Claude in Chrome bridge disconnect error (**96** tks) - Error message shown when a Claude in Chrome tool call fails because the Chrome extension disconnects mid-operation.
* Tool Description: Claude in Chrome bridge timeout error (**88** tks) - Error message shown when a Claude in Chrome tool does not respond before timing out.
* Tool Description: Claude in Chrome find (**113** tks) - Describes the Claude in Chrome find tool for locating page elements by natural language or text content.
* Tool Description: Claude in Chrome get page text (**66** tks) - Describes the Claude in Chrome get\_page\_text tool for extracting raw text content from a page.
* Tool Description: Claude in Chrome read console messages (**109** tks) - Describes the Claude in Chrome read\_console\_messages tool for reading filtered browser console output.
* Tool Description: Claude in Chrome read network requests (**104** tks) - Describes the Claude in Chrome read\_network\_requests tool for inspecting HTTP requests made by the current page.
* Tool Description: Claude in Chrome read page (**104** tks) - Describes the Claude in Chrome read\_page tool for retrieving an accessibility tree of page elements.
* Tool Description: Claude in Chrome shortcuts execute (**61** tks) - Describes the Claude in Chrome shortcuts\_execute tool for starting a shortcut or workflow in a side panel.
* Tool Description: Claude in Chrome switch browser (**88** tks) - Describes the Claude in Chrome switch\_browser tool for letting the user choose a browser from inside connected Chrome extensions.
* Tool Description: Claude in Chrome tabs context (**90** tks) - Describes the Claude in Chrome tabs\_context\_mcp tool for retrieving the current MCP tab group context.
* Tool Description: Code review command (**138** tks) - Describes the code review command and its effort levels, PR comment mode, and fix mode.
* Tool Description: Computer computer\_batch (**100** tks) - Describes the computer-use computer\_batch tool for executing a sequence of computer actions in one call.
* Tool Description: Computer hold\_key (**67** tks) - Describes the computer-use hold\_key tool for pressing and holding keys or key combinations with allowlist and system-combo checks.
* Tool Description: Computer left\_mouse\_down (**78** tks) - Describes the computer-use left\_mouse\_down tool for holding the left mouse button at the current cursor position.
* Tool Description: Computer left\_mouse\_up (**67** tks) - Describes the computer-use left\_mouse\_up tool for releasing the left mouse button at the current cursor position.
* Tool Description: Computer request\_access (**82** tks) - Describes the computer-use request\_access tool for asking user permission to control applications in the session.
* Tool Description: Computer type (**59** tks) - Describes the computer-use type tool for entering text into the focused allowlisted application.
* Tool Description: Computer zoom (**91** tks) - Describes the computer-use zoom tool for taking read-only higher-resolution screenshots of regions.
* Tool Description: Computer (**161** tks) - Main description for the Chrome browser computer automation tool.
* Tool Description: Cowork onboarding role picker (**188** tks) - Describes the Cowork onboarding role-picker tool that returns a selected or typed role and should only be used while setting up Cowork for the user's job function.
* Tool Description: Cowork plugin creation (**86** tks) - Describes the command for creating or customizing Cowork plugins for an organization.
* Tool Description: CronCreate (**850** tks) - Describes the CronCreate tool for enqueuing one-shot or recurring cron-based jobs with jitter and off-minute scheduling guidance.
* Tool Description: DesignSync (**0** tks) - Describes the DesignSync tool for reading and updating claude.ai/design design-system projects, including project listing, plan finalization, file writes and deletes, and asset registration.
* Tool Description: Edit minimal old\_string guidance (**92** tks) - Additional Edit guidance to keep old\_string minimal and unique or use replace\_all.
* Tool Description: Edit single replacement (**120** tks) - Tool description for performing exact string replacement in a file, including prior-read and line-prefix requirements.
* Tool Description: Edit (**202** tks) - Tool for performing exact string replacements in files.
* Tool Description: EnterPlanMode (**881** tks) - Tool description for entering plan mode to explore and design implementation approaches.
* Tool Description: EnterWorktree (**774** tks) - Tool description for the EnterWorktree tool.
* Tool Description: ExitPlanMode (**417** tks) - Description for the ExitPlanMode tool, which presents a plan dialog for the user to approve.
* Tool Description: ExitWorktree (**527** tks) - Roughly, the reverse of the ExitWorktree.
* Tool Description: Glob compact (**0** tks) - Compact Glob tool description served to newer models — file pattern matching returning paths sorted by modification time.
* Tool Description: Glob (**0** tks) - Tool description for file pattern matching and searching by name.
* Tool Description: Grep compact (**0** tks) - Compact Grep tool description served to newer models — ripgrep-backed content search preferred over raw grep/rg, with permission-UI integration.
* Tool Description: Grep (**300** tks) - Tool description for content search using ripgrep.
* Tool Description: LSP (**298** tks) - Description for the LSP tool.
* Tool Description: ListMcpResourcesTool prompt (**83** tks) - Tool prompt for listing MCP resources and explaining the optional server parameter.
* Tool Description: ListMcpResourcesTool (**82** tks) - Tool description for listing available MCP resources from all configured servers or a specific server.
* Tool Description: NotebookEdit (**194** tks) - Tool description for editing Jupyter notebook cells by replacing, inserting, or deleting a cell using cell IDs from the read tool.
* Tool Description: PowerShell (**1914** tks) - Describes the PowerShell command execution tool with syntax guidance, timeout settings, and instructions to prefer specialized tools over PowerShell for file operations.
* Tool Description: PushNotification (**261** tks) - Tool description for PushNotification. This is a tool that sends a desktop notification in the user's terminal and pushes to their phone if Remote Control is connected.
* Tool Description: REPL (**715** tks) - Describes the REPL tool, a JavaScript programming interface for looping, branching, and composing Claude Code tool calls as async functions.
* Tool Description: ReadFile compact (**0** tks) - Compact file-read tool description served to newer models — absolute path, default line cap, and image/PDF/notebook handling.
* Tool Description: ReadFile (**412** tks) - Tool description for reading files.
* Tool Description: RemoteTrigger prompt (**189** tks) - Tool prompt for calling the claude.ai RemoteTrigger API to list, get, create, update, or run scheduled remote agent routines.
* Tool Description: SendMessageTool (**0** tks) - Agent teams version of SendMessageTool.
* Tool Description: SendUserFile (**201** tks) - Describes the SendUserFile tool for surfacing generated deliverable files to the user, with optional captions and normal or proactive status.
* Tool Description: ShowOnboardingRolePicker (**38** tks) - ShowOnboardingRolePicker: presents a row of clickable role chips during Cowork onboarding.
* Tool Description: Skill (**0** tks) - Tool description for executing skills in the main conversation.
* Tool Description: Task Get (**182** tks) - Retrieve a task by ID with full details and comments.
* Tool Description: TaskCreate (**499** tks) - Tool description for TaskCreate tool.
* Tool Description: TaskList (**267** tks) - Description for the TaskList tool, which lists all tasks in the task list.
* Tool Description: TaskUpdate (**586** tks) - Description for the TaskUpdate tool, which updates Claude's task list.
* Tool Description: TodoWrite compact (**108** tks) - Compact tool description for creating and updating a session task list with content, status, and activeForm fields.
* Tool Description: TodoWrite proactive update guidance (**65** tks) - Concise TodoWrite guidance to proactively track progress with one in-progress task and activeForm values.
* Tool Description: TodoWrite (**2037** tks) - Tool description for creating and managing task lists.
* Tool Description: WebFetch private URL warning (**173** tks) - Warns that WebFetch fails for authenticated or private URLs and includes the standard WebFetch usage notes.
* Tool Description: WebFetch (**297** tks) - Tool description for web fetch functionality.
* Tool Description: WebSearch (**319** tks) - Tool description for web search functionality.
* Tool Description: Workflow (**0** tks) - Describes the Workflow tool for running deterministic multi-subagent orchestration scripts, including opt-in requirements, script metadata, agent hooks, concurrency, budgeting, quality patterns, and resume behavior.
* Tool Description: Write (**129** tks) - Tool for writing files to the local filesystem.
* Tool Description: claude.ai Project (**685** tks) - Read and write the claude.ai Project bound to the session — a shared, persistent knowledge container — via project\_info/read/search/write/delete methods, including knowledge-budget enforcement, the claude/ namespace default for agent-written docs, prompt-cache churn warnings, and treating doc contents as untrusted data.

**Additional notes for some Tool Descriptions**

* Tool Description: Agent (simple usage notes) (**333** tks) - Simplified usage notes for the Agent tool, including when to delegate, fork behavior, resumption, worktree isolation, background execution, parallel launches, and context restrictions.
* Tool Description: Agent (usage notes) (**0** tks) - Usage notes and instructions for the Task/Agent tool, including guidance on launching subagents, background execution, resumption, and worktree isolation.
* Tool Description: Agent (when to launch subagents) (**0** tks) - Describes _when_ to use the Agent tool - for launching specialized subagent subprocesses to autonomously handle complex multi-step tasks.
* Tool Description: AskUserQuestion (preview field) (**134** tks) - Instructions for using the HTML preview field on single-select question options to display visual artifacts like UI mockups, code snippets, and diagrams.
* Tool Description: Background monitor (streaming events) (**1425** tks) - Describes the background monitor tool that streams stdout events from long-running scripts as chat notifications, with guidelines on script quality, output volume, and selective filtering.
* Tool Description: Bash (Git commit and PR creation instructions) (**0** tks) - Instructions for creating git commits and GitHub pull requests.
* Tool Description: Bash (alternative — communication) (**18** tks) - Bash tool alternative: output text directly instead of echo/printf.
* Tool Description: Bash (alternative — content search) (**27** tks) - Bash tool alternative: use Grep for content search instead of grep/rg.
* Tool Description: Bash (alternative — edit files) (**27** tks) - Bash tool alternative: use Edit for file editing instead of sed/awk.
* Tool Description: Bash (alternative — file search) (**26** tks) - Bash tool alternative: use Glob for file search instead of find/ls.
* Tool Description: Bash (alternative — read files) (**27** tks) - Bash tool alternative: use Read for file reading instead of cat/head/tail.
* Tool Description: Bash (alternative — write files) (**29** tks) - Bash tool alternative: use Write for file writing instead of echo/cat.
* Tool Description: Bash (built-in tools note) (**53** tks) - Note that built-in tools provide better UX than Bash equivalents.
* Tool Description: Bash (git — avoid destructive ops) (**58** tks) - Bash tool git instruction: consider safer alternatives to destructive operations.
* Tool Description: Bash (git — never skip hooks) (**59** tks) - Bash tool git instruction: never skip hooks or bypass signing unless user requests it.
* Tool Description: Bash (git — prefer new commits) (**22** tks) - Bash tool git instruction: prefer new commits over amending.
* Tool Description: Bash (maintain cwd) (**81** tks) - Bash tool instruction: use absolute paths and avoid cd.
* Tool Description: Bash (no newlines) (**24** tks) - Bash tool instruction: do not use newlines to separate commands.
* Tool Description: Bash (overview) (**19** tks) - Opening line of the Bash tool description.
* Tool Description: Bash (parallel commands) (**72** tks) - Bash tool instruction: run independent commands as parallel tool calls.
* Tool Description: Bash (prefer dedicated tools bullet) (**72** tks) - Bulleted warning to prefer dedicated tools over Bash for find, grep, cat, etc.
* Tool Description: Bash (prefer dedicated tools) (**71** tks) - Warning to prefer dedicated tools over Bash for find, grep, cat, etc.
* Tool Description: Bash (quote file paths) (**35** tks) - Bash tool instruction: quote file paths containing spaces.
* Tool Description: Bash (sandbox — adjust settings) (**26** tks) - Work with user to adjust sandbox settings on failure.
* Tool Description: Bash (sandbox — default to sandbox) (**38** tks) - Default to sandbox; only bypass when user asks or evidence of sandbox restriction.
* Tool Description: Bash (sandbox — evidence list header) (**15** tks) - Header for list of sandbox-caused failure evidence.
* Tool Description: Bash (sandbox — evidence: access denied) (**15** tks) - Sandbox evidence: access denied to paths outside allowed directories.
* Tool Description: Bash (sandbox — evidence: network failures) (**17** tks) - Sandbox evidence: network connection failures to non-whitelisted hosts.
* Tool Description: Bash (sandbox — evidence: operation not permitted) (**18** tks) - Sandbox evidence: operation not permitted errors.
* Tool Description: Bash (sandbox — evidence: unix socket errors) (**11** tks) - Sandbox evidence: unix socket connection errors.
* Tool Description: Bash (sandbox — explain restriction) (**36** tks) - Explain which sandbox restriction caused the failure.
* Tool Description: Bash (sandbox — failure evidence condition) (**48** tks) - Condition: command failed with evidence of sandbox restrictions.
* Tool Description: Bash (sandbox — mandatory mode) (**34** tks) - Policy: all commands must run in sandbox mode.
* Tool Description: Bash (sandbox — no exceptions) (**17** tks) - Commands cannot run outside sandbox under any circumstances.
* Tool Description: Bash (sandbox — no sensitive paths) (**36** tks) - Do not suggest adding sensitive paths to sandbox allowlist.
* Tool Description: Bash (sandbox — per-command) (**52** tks) - Treat each command individually; default to sandbox for future commands.
* Tool Description: Bash (sandbox — response header) (**17** tks) - Header for how to respond when seeing sandbox-caused failures.
* Tool Description: Bash (sandbox — retry without sandbox) (**33** tks) - Immediately retry with dangerouslyDisableSandbox on sandbox failure.
* Tool Description: Bash (sandbox — tmpdir) (**58** tks) - Use $TMPDIR for temporary files in sandbox mode.
* Tool Description: Bash (sandbox — user permission prompt) (**14** tks) - Note that disabling sandbox will prompt user for permission.
* Tool Description: Bash (semicolon usage) (**29** tks) - Bash tool instruction: use semicolons when sequential order matters but failure does not.
* Tool Description: Bash (sequential commands) (**42** tks) - Bash tool instruction: chain dependent commands with &&.
* Tool Description: Bash (sleep — keep short) (**22** tks) - Bash tool instruction: keep sleep duration to 1-5 seconds.
* Tool Description: Bash (sleep — no polling background tasks) (**37** tks) - Bash tool instruction: do not poll background tasks, wait for notification.
* Tool Description: Bash (sleep — run immediately) (**21** tks) - Bash tool instruction: do not sleep between commands that can run immediately.
* Tool Description: Bash (sleep — use check commands) (**34** tks) - Bash tool instruction: use check commands rather than sleeping when polling.
* Tool Description: Bash (timeout) (**83** tks) - Bash tool instruction: optional timeout configuration.
* Tool Description: Bash (verify parent directory) (**38** tks) - Bash tool instruction: verify parent directory before creating files.
* Tool Description: Bash (working directory) (**37** tks) - Bash tool note about working directory persistence and shell state.
* Tool Description: CronCreate (durability note) (**122** tks) - CronCreate insert (shown when durable-cron is enabled) explaining the durable: true vs false trade-off.
* Tool Description: EnterPlanMode (ambiguous tasks) (**195** tks) - Tool for entering plan mode when task has ambiguity.
* Tool Description: SendMessageTool (non-agent-teams) (**226** tks) - Send a message the user will read, describes this tool well.
* Tool Description: SendUserMessage (verbatim) (**114** tks) - Describes the concise SendUserMessage tool variant for sending verbatim user-visible messages with normal or proactive status.
* Tool Description: Snooze (delay and reason guidance) (**732** tks) - Extends the snooze tool description with guidance on choosing delaySeconds relative to the 5-minute prompt cache TTL and writing informative reason fields.
* Tool Description: TaskList (teammate workflow) (**133** tks) - Conditional section appended to TaskList tool description.
* Tool Description: ToolSearch (second part) (**0** tks) - The bulk of the tool description.
* Tool Description: WebFetch (concise) (**159** tks) - Concise tool description for WebFetch covering URL fetching, private URL limitations, redirects, and caching.
* Tool Description: WebSearch (concise) (**88** tks) - Describes the concise WebSearch tool variant with US-only results, current-month guidance, domain filters, and required sources.
* Tool Description: Write (read existing file first) (**84** tks) - Tool description for Write in environments where existing files must be read before overwrite.
* Tool Description: request\_teach\_access (part of teach mode) (**139** tks) - Describes a tool that requests permission to guide the user through a task step-by-step using fullscreen tooltip overlays instead of direct access.
* Tool Parameter: Bash run\_in\_background guidance (**92** tks) - Explains Bash run\_in\_background behavior and that commands do not need a trailing ampersand.
* Tool Parameter: Bash run\_in\_background note (**74** tks) - Notes that Bash commands can use run\_in\_background when the result is not needed immediately.
* Tool Parameter: Claude in Chrome JavaScript code (**103** tks) - Describes the JavaScript code parameter for the Claude in Chrome JavaScript execution tool.
* Tool Parameter: Computer action (**251** tks) - Action parameter options for the Chrome browser computer tool.
* Tool Parameter: SendUserMessage attachments (**75** tks) - Describes optional SendUserMessage attachments as local file paths or pre-resolved file objects.

### Skills

Built-in skill prompts for specialized tasks.

* Skill: /catch-up periodic heartbeat (**1591** tks) - Skill definition for the /catch-up periodic heartbeat that scans current priorities, triages actionable changes, reports a short digest, and updates catch-up state.
* Skill: /code-review efficiency dimension (**106** tks) - Code-review pass that surfaces wasted effort the diff adds — duplicate computation or I/O, avoidable serialization, large scopes held by closures — and points to the cheaper option.
* Skill: /design-sync package source shape (**16174** tks) - Shape-specific /design-sync instructions for syncing a React design system from a built package without Storybook.
* Skill: /dream memory consolidation (**512** tks) - Skill definition for the /dream nightly housekeeping job that consolidates recent logs and transcripts into persistent memory topics, learnings, and a pruned MEMORY.md index.
* Skill: /init CLAUDE.md and skill setup (new version) (**5412** tks) - A comprehensive onboarding flow for setting up CLAUDE.md and related skills/hooks in the current repository, including codebase exploration, user interviews, and iterative proposal refinement.
* Skill: /insights report output (**182** tks) - Formats and displays the insights usage report results after the user runs the /insights slash command.
* Skill: /loop cloud-first scheduling offer (**510** tks) - Decision tree for offering cloud-based scheduling before falling back to local session loops in the /loop command.
* Skill: /loop local runtime note (**96** tks) - Conditional /loop confirmation note explaining that local loops run only until the current session closes.
* Skill: /loop self-pacing mode (**678** tks) - Instructs Claude how to self-pace a recurring loop by arming event monitors as primary wake signals and scheduling fallback heartbeat delays between iterations.
* Skill: /loop slash command (dynamic mode) (**514** tks) - Parses user input into an interval and prompt for scheduling recurring or dynamically self-paced loop executions.
* Skill: /loop slash command (**969** tks) - Parses user input into an interval and prompt, converts the interval to a cron expression, and schedules a recurring task.
* Skill: /morning-checkin daily brief (**1576** tks) - Skill definition for the /morning-checkin scheduled task that prepares a daily calendar and inbox digest, schedules pre-meeting check-ins, and records the day’s top priority.
* Skill: /pre-meeting-checkin event brief (**491** tks) - Skill definition for the /pre-meeting-checkin task that gathers event materials, recent thread context, open questions, and a concise meeting brief.
* Skill: /stuck (background-daemon diagnostics) (**181** tks) - The background-daemon troubleshooting section of the /stuck skill.
* Skill: /stuck slash command (**964** tks) - Diagnozse frozen or slow Claude Code sessions.
* Skill: Agent Design Patterns (**2029** tks) - Reference guide covering decision heuristics for building agents on the Claude API, including tool surface design, context management, caching strategies, and composing tool calls.
* Skill: Build with Claude API (reference guide) (**703** tks) - Template for presenting language-specific reference documentation with quick task navigation.
* Skill: Building LLM-powered applications with Claude (**11477** tks) - Guides Claude in building LLM-powered applications using the Anthropic SDK, covering language detection, API surface selection (Claude API vs Managed Agents), model defaults, thinking/effort configuration, and language-specific documentation reading.
* Skill: Claude Code configuration guide (**975** tks) - Skill instructions for answering Claude Code configuration questions by checking the running build, bundled references, and current documentation.
* Skill: Code Review (Angle B — removed-behavior auditor) (**94** tks) - Code-review finder angle that, for each deleted or rewritten line, names the behavior it guaranteed and confirms the new code still guarantees it.
* Skill: Code Review (Angle C — cross-file tracer) (**88** tks) - Code-review finder angle that follows each changed function out to its callers, checking the diff hasn't broken a call-site contract.
* Skill: Code Review (Angle D — language-pitfall specialist) (**101** tks) - Code-review finder angle that hunts for the well-known traps of the diff's language or framework.
* Skill: Code Review (Angle E — wrapper/proxy correctness) (**126** tks) - Code-review finder angle for wrapping types (caches, proxies, decorators), checking every method forwards faithfully to the wrapped object.
* Skill: Code Review (Output — findings JSON array) (**137** tks) - Defines the code-review skill's result shape: a JSON array of findings carrying file, line, summary, and failure\_scenario.
* Skill: Code Review (Phase 0 — gather the diff) (**135** tks) - Opening step of the code-review skill: assemble the unified diff to review with git diff.
* Skill: Code Review (Phase 2 — verify, 3-state) (**125** tks) - Precision-tier verification step: run one verifier per candidate finding, each voting CONFIRMED, PLAUSIBLE, or REFUTED.
* Skill: Code Review (Phase 2 — verify, recall-biased) (**137** tks) - Recall-tier verification step: one verifier per candidate finding, biased toward keeping anything plausible.
* Skill: Code Review (Phase 3 — sweep for gaps) (**131** tks) - Final code-review sweep: a clean-slate reviewer re-reads the diff to catch defects the earlier passes missed.
* Skill: Code Review (altitude dimension) (**61** tks) - Code-review dimension: check whether each change is implemented at the right depth rather than as a fragile special case.
* Skill: Code Review (conventions dimension) (**0** tks) - Code-review dimension: flag diff lines that break a rule stated in an applicable CLAUDE.md (user, repo-root, or ancestor-directory), quoting the exact rule and offending line, and emit nothing when no CLAUDE.md governs the change.
* Skill: Computer Use MCP (**1206** tks) - Instructions for using computer-use MCP tools including tool selection tiers, app access tiers, link safety, and financial action restrictions.
* Skill: Cowork plugin authoring (**4791** tks) - Skill instructions for creating or customizing Cowork plugins, including mode selection, research, implementation, packaging, connector replacement, and plugin delivery.
* Skill: Create verifier skills (**2580** tks) - Prompt for creating verifier skills for the Verify agent to automatically verify code changes.
* Skill: Debugging (**417** tks) - Instructions for debugging an issue that the user is encountering in the Claude Code session.
* Skill: Design sync Storybook source shape (**18509** tks) - Design sync sub-skill instructions for using a repo's Storybook as the fidelity oracle when building, validating, matching, uploading, and re-syncing component previews.
* Skill: Design sync (**0** tks) - Skill for syncing a React design system to claude.ai/design by configuring the target project, running the converter, verifying previews, and uploading verified artifacts.
* Skill: Dynamic pacing loop execution (**598** tks) - Step-by-step instructions for executing a dynamic pacing loop that runs tasks, arms persistent monitors for event-gated waits, schedules fallback heartbeat ticks, and handles task notifications.
* Skill: Generate permission allowlist from transcripts (**2408** tks) - Analyzes session transcripts to extract frequently used read-only tool-call patterns and adds them to the project's .claude/settings.json permission allowlist to reduce permission prompts.
* Skill: Model migration guide (**32310** tks) - Step-by-step instructions for migrating existing code to newer Claude models, covering breaking changes, deprecated parameters, per-SDK syntax, prompt-behavior shifts, and migration checklists.
* Skill: Run CLI tool example (**499** tks) - Example file for the Run app skill showing how to document building, invoking, and testing a CLI tool.
* Skill: Run Electron desktop GUI app example (**4625** tks) - Example file for the Run app skill showing how to launch an Electron desktop app under xvfb and drive it through a Playwright REPL driver.
* Skill: Run TUI interactive terminal app example (**1004** tks) - Example file for the Run app skill showing how to drive an interactive terminal app with tmux, readiness polling, pane capture, key references, and cleanup.
* Skill: Run app (**999** tks) - Skill for launching and driving the current project's app through its real runtime surface using project-specific run skills or fallback patterns.
* Skill: Run browser-driven web app example (**1002** tks) - Example file for the Run app skill showing how to start a web dev server, drive it with chromium-cli, capture screenshots, and document app-specific gotchas.
* Skill: Run library SDK example (**653** tks) - Example file for the Run app skill showing how to document building, testing, and smoke-checking a library or SDK at its public package boundary.
* Skill: Run skill generator (**4681** tks) - Skill for authoring or improving a project-specific run skill that documents verified build, launch, runtime driving, and troubleshooting steps.
* Skill: Run skill template (**1216** tks) - Template file for the Run skill generator showing the frontmatter and section structure for a project-specific run skill.
* Skill: Run web server API example (**890** tks) - Example file for the Run app skill showing how to document a server or API lifecycle with background launch, readiness checks, curl verification, and shutdown.
* Skill: Schedule recurring cron and execute immediately (compact) (**173** tks) - Instructions for creating a recurring cron job, confirming the schedule with the user, and immediately executing the parsed prompt without waiting for the first cron fire.
* Skill: Schedule recurring cron and run immediately (**271** tks) - Converts an interval to a cron expression, schedules a recurring task via the cron creation tool, confirms to the user, and immediately executes the task without waiting for the first cron fire.
* Skill: Team onboarding guide (**521** tks) - Template for onboarding a new teammate to a team's Claude Code setup, walking them through usage stats, setup checklists, MCP servers, skills, and team tips in a warm conversational style.
* Skill: Update Claude Code Config (**1195** tks) - Skill for modifying Claude Code configuration file (settings.json).
* Skill: Update config description (**170** tks) - Update-config skill description (settings.json hooks, perms, env).
* Skill: Update config settings file locations (**792** tks) - Where Claude Code stores settings.json across scopes.
* Skill: Verify CLI changes (example for Verify skill) (**565** tks) - Example workflow for verifying a CLI change, as part of the Verify skill.
* Skill: Verify server/API changes (example for Verify skill) (**612** tks) - Example workflow for verifying a server/API change, as part of the Verify skill.
* Skill: Verify skill (**2932** tks) - Skill for opinionated verification workflow for validating code changes.
* Skill: update-config (7-step verification flow) (**1160** tks) - A skill that guides Claude through a 7-step process to construct and verify hooks for Claude Code, ensuring they work correctly in the user's specific project environment.

## About

 All parts of Claude Code's system prompt, 27 builtin tool descriptions, sub agent prompts (Plan/Explore/Task), utility prompts (CLAUDE.md, compact, statusline, magic docs, WebFetch, Bash cmd, security review, agent creation). Updated for each Claude Code version.

### Topics

 system-prompts  claude-code  claude-code-system-prompts 

### Resources

 Readme 

### License

 MIT license 

###  Uh oh!

There was an error while loading. Please reload this page.

Activity 

Custom properties 

### Stars

**11.1k** stars 

### Watchers

**123** watching 

### Forks

**1.9k** forks 

 Report repository 

## Releases160

v2.1.178  Latest Jun 16, 2026 

\+ 159 releases

## Packages0

###  Uh oh!

There was an error while loading. Please reload this page.

## Contributors 

###  Uh oh!

There was an error while loading. Please reload this page.

## Languages

* JavaScript 100.0%

## Footer

 © 2026 GitHub, Inc. 

### Footer navigation

* Terms
* Privacy
* Security
* Status
* Community
* Docs
* Contact
* Manage cookies
* Do not share my personal information

 You can’t perform that action at this time.