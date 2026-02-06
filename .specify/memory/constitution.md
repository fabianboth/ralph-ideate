# Autonomous Review Loop Constitution

## Core Principles

### I. MVP approach
Focus on a core set of features creating a lean but useful core value loop for the user. Avoid feature creep; do one thing well. If a feature doesn't directly contribute to the core value proposition, it should be deferred.

### II. Modern & Clean Code
Code must be clean, readable, type-safe, and linted. We avoid legacy patterns and embrace the "bleeding edge" where it offers stability and improved DX.

### III. Automated Verification
All changes must pass automated checks (lint, typecheck, test). New features should include tests where applicable. We value confidence in our deployments; automation is the key to maintaining velocity without sacrificing quality.

### IV. Reusable Components
Prefer reusing existing components and code, creating well maintainable, modular and reusable code with good interfaces.

### Code Style
- Enforced strict typing / linting / typechecking
- Keep functions small and focused
- Prefer composition over complexity

**Version**: 1.0.0 | **Ratified**: 2025-02-05
