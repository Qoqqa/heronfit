# Instructions for Generating Commit Messages for HeronFit Project

## Format: Conventional Commits

Follow the Conventional Commits specification: `https://www.conventionalcommits.org/`

The basic format is:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Header (`<type>[optional scope]: <description>`)

- **Type:** Must be one of the following:
  - `feat`: A new feature for the user.
  - `fix`: A bug fix for the user.
  - `build`: Changes that affect the build system or external dependencies (e.g., `pubspec.yaml`, `gradle`, `fastlane`).
  - `chore`: Other changes that don't modify `src` or `test` files (e.g., updating dependencies, documentation changes).
  - `ci`: Changes to CI configuration files and scripts.
  - `docs`: Documentation only changes.
  - `perf`: A code change that improves performance.
  - `refactor`: A code change that neither fixes a bug nor adds a feature.
  - `revert`: Reverts a previous commit.
  - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
  - `test`: Adding missing tests or correcting existing tests.
- **Scope (Optional):** A noun describing the section of the codebase affected (e.g., `auth`, `booking`, `workout`, `profile`, `core`, `theme`, `ci`, `deps`). Use lowercase.
- **Description:** A short, imperative mood summary of the change (e.g., "add login screen", "fix user profile update bug"). Use lowercase. Do not end with a period.

**Example Headers:**

- `feat(auth): add email verification screen`
- `fix(workout): correct calculation for total weight lifted`
- `refactor(core): simplify supabase service wrapper`
- `docs: update custom instructions for recommendations`
- `chore: update riverpod dependency to latest version`
- `style(theme): adjust primary color shade`
- `test(booking): add unit tests for booking controller`

## Body (Optional)

- Provide **context** and **reasoning** for the change. Explain _why_ the change was made, not just _what_ changed.
- Describe the **previous behavior** if fixing a bug.
- Mention **alternatives considered** if applicable.
- Use bullet points for longer explanations or lists of changes.
- Reference relevant issue numbers (e.g., `Closes #123`, `Refs #456`).

## Footer (Optional)

- **Breaking Changes:** Start with `BREAKING CHANGE:` followed by a description of the breaking change and migration instructions.
- **Issue References:** Use keywords like `Closes`, `Fixes`, `Refs` followed by issue numbers (e.g., `Closes #12`, `Refs #34, #56`).

## General Guidelines

- **Be Comprehensive:** Ensure the commit message accurately reflects _all_ changes made in the commit. List the key files or modules affected if helpful in the body.
- **Explain the "Why":** Focus on the motivation behind the change.
- **Imperative Mood:** Write the description as if giving a command (e.g., "fix bug" not "fixed bug" or "fixes bug").
- **Keep Lines Short:** Aim for lines no longer than 72 characters in the body and footer for readability.
