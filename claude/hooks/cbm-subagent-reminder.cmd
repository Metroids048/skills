@echo off
REM SubagentStart reminder for codebase-memory-mcp (Windows wrapper).
echo {"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"Code discovery: prefer codebase-memory-mcp tools (search_graph, trace_path, get_code_snippet, query_graph, get_architecture, search_code) over grep/file-read for navigating code. Use Grep/Glob/Read for text, configs, and non-code files."}}
exit /b 0
