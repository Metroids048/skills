@echo off
REM SessionStart reminder for codebase-memory-mcp (Windows wrapper).
echo CRITICAL - Code Discovery Protocol:
echo 1. ALWAYS use codebase-memory-mcp tools FIRST for ANY code exploration:
echo    - search_graph(name_pattern/label/qn_pattern) to find functions/classes/routes
echo    - trace_path(function_name, mode=calls^|data_flow^|cross_service) for call chains
echo    - get_code_snippet(qualified_name) for exact symbol source (precise ranges)
echo    - query_graph(query) for complex Cypher patterns
echo    - get_architecture(aspects) for project structure
echo    - search_code(pattern) for text search (graph-augmented grep)
echo 2. Use Grep/Glob/Read freely for text, configs, non-code files, and
echo    always Read a file before editing it.
echo 3. If a project is not indexed yet, run index_repository FIRST.
exit /b 0
