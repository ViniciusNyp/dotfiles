- when I ask to fix a test don't change the implementation by default, if you see that the problem is objectively in the implementation, just tell me instead of changing it

## Multi-Project Reference Access

- You have access to multiple company projects in `/Users/viniciusnyp/everest/`:
  - **appserver** - Backend/appserver codebase (reference for backend patterns)
  - **ui** - UI codebase (reference for UI patterns)
  - **content** / **content-v2** - Content packages (reference implementations)
  - **kernel** - Core system
  - **everdocs** - Documentation
  - **vscode-extension** - VSCode extension
  - **temp**, **temp2** - Sandbox projects for active development

- When helping with implementations in sandbox projects (temp, temp2), you should:
  - **Proactively search** `appserver`, `ui`, and `content` projects for similar patterns/examples
  - **Reference existing implementations** to maintain consistency with company patterns
  - **Learn from existing code** rather than inventing new approaches
  - **Search across projects** when asked about features or patterns

- Use these projects as reference libraries to understand:
  - How appserver features are typically implemented
  - UI component patterns and best practices
  - How content packages are structured
  - Real-world examples of Everest patterns