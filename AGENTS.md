# Repository work checklist

Read [CONTRIBUTING.md](CONTRIBUTING.md) and follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

- Keep each change focused and follow the conventions in the affected files.
- This is a toolkit assembly repository. Make package implementation changes
  in the appropriate package repository and link related changes.
- Do not change submodule revisions, dependencies, or generated files as a side
  effect of unrelated work. Explain intentional revision updates in the commit
  and pull request.
- Use descriptive commit subjects. Explain non-obvious decisions in the commit
  body and reference the relevant issue when available.
- Include the problem, resulting behavior, scope, validation results, and known
  limitations in every pull request. For build or runtime validation, record the
  platform, toolchain, and relevant CMake options.
- Run checks appropriate to the change. Report checks actually performed and
  any coverage gaps; do not claim disabled packages or tests were exercised.
- Keep credentials and private imaging data out of commits and attachments.
