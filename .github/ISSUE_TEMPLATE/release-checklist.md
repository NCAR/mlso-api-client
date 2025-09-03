---
name: Release checklist
about: Checklist for a release
title: "Release vX.Y.Z"
labels: release
assignees: mgalloy
projects: ["NCAR/49"]
---

### Pre-release check

- [ ] add date to version line in `CHANGELOG.md` and make sure it is up-to-date
- [ ] check that version to release in `CHANGELOG.md` matches version in `pyproject.toml`

### Release to production

- [ ] merge master to production, `git checkout release; git merge main`
- [ ] push production to origin, `git push`
- [ ] tag production with release name of the form vX.Y.Z, e.g., `git tag -a v0.1.0`
- [ ] push tags, e.g., `git push --tags`

### Post-release check

- [ ] send email with new release notes to iguana, detoma, and observers
- [ ] in main, increment version in `pyproject.toml` and `CHANGELOG.md`
- [ ] install new version, i.e., `pip install -e .[dev]`

