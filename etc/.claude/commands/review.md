# Claude Code Review Command

## Purpose
Perform a comprehensive code review autonomously, identifying potential issues and suggesting improvements.

## Instructions
When this command is invoked, you should:

1. **Identify Review Scope**
   - Determine which files need review (modified files, new files, or specified files)
   - Use git status and git diff to identify changes if not specified
   - Focus on code changes rather than documentation unless specifically requested

2. **Review Categories**
   Analyze each file for:
   
   **Code Quality**
   - Logic errors or potential bugs
   - Edge case handling
   - Error handling and validation
   - Code duplication
   - Dead code or unused variables
   
   **Security**
   - Potential security vulnerabilities
   - Input validation issues
   - Authentication/authorization concerns
   - Sensitive data exposure
   - SQL injection, XSS, or other injection risks
   
   **Performance**
   - Inefficient algorithms or data structures
   - N+1 query problems
   - Memory leaks or excessive memory usage
   - Unnecessary computations
   
   **Maintainability**
   - Code clarity and readability
   - Naming conventions
   - Function/method complexity
   - Proper abstractions
   - Documentation needs
   
   **Best Practices**
   - Language-specific idioms and conventions
   - Framework best practices
   - Testing coverage suggestions
   - Design pattern opportunities

3. **Output Format**
   Structure your review as follows:
   
   ```markdown
   # Code Review Report
   
   ## Summary
   [Brief overview of reviewed files and overall assessment]
   
   ## Critical Issues 🚨
   [Issues that must be fixed before proceeding]
   
   ## Important Suggestions ⚠️
   [Strongly recommended improvements]
   
   ## Minor Improvements 💡
   [Nice-to-have enhancements]
   
   ## Positive Aspects ✅
   [Well-implemented features or good practices observed]
   
   ## File-by-File Review
   
   ### [filename]
   - **Issue**: [description]
     - **Location**: [file:line]
     - **Severity**: [Critical/High/Medium/Low]
     - **Suggestion**: [how to fix]
   ```

4. **Review Process**
   - Start by understanding the context and purpose of changes
   - Review in order of importance: critical security/logic issues first
   - Provide actionable feedback with specific examples
   - Suggest concrete improvements, not just identify problems
   - Balance criticism with recognition of good practices

5. **Special Considerations**
   - For new features: verify completeness and edge cases
   - For refactoring: ensure behavior preservation
   - For bug fixes: confirm the fix addresses root cause
   - For performance improvements: validate the optimization

## Example Usage
```
# Review all modified files
/review

# Review specific files
/review src/api/users.ts src/utils/validation.ts

# Review with focus area
/review --focus security
```

Remember: Be thorough but constructive. The goal is to improve code quality while maintaining developer productivity.