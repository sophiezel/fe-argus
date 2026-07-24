# Argus (fe-argus)

Glossary for the **fe-argus** skill: coding quality gates and scenario playbooks that steer AI-assisted frontend implementation.

## Language

**Coding Gate**:
The write-time protocol that requires Always-on rules plus progressive loading of coding canon and scenario playbooks before changing frontend code.
_Avoid_: quality checklist, pre-commit lint

**Tier**:
A soft judgment label (T0 / T1 / T2) for how much coding-canon context to load; default is T1; not a hard file-count gate.
_Avoid_: priority, severity, sprint size

**Coding Canon**:
Executable coding rules under `references/coding/` (simplicity, robustness, framework anti-patterns, JS fundamentals).
_Avoid_: style guide, lint rules, architecture patterns doc

**Scenario Playbook**:
A build-time guide under `references/scenarios/` for a concrete product scenario: standard solutions plus anti-patterns.
_Avoid_: pitfall, postmortem, checklist item

**On-demand Hit**:
Loading only the Scenario Playbooks matched by task signals via the scenarios INDEX—not reading the whole scenarios tree.
_Avoid_: full corpus load, eager load all scenarios

**L0 Index**:
The scenarios router that maps feature, symptom, and platform signals to L1 and L2 playbook paths.
_Avoid_: knowledge map, pitfalls INDEX

**L1 Domain Playbook**:
Cross-environment scenario guidance (shared solutions and anti-patterns for a domain such as search or form input).
_Avoid_: platform guide, env delta

**L2 Env Delta**:
Environment-specific increments (web / hybrid / rn / miniprogram) that only document differences from the L1 playbook.
_Avoid_: full platform rewrite, duplicate L1

**Soft Composition**:
Other workflows may opt into this skill’s Coding Gate; this skill does not hard-depend on or patch those workflows.
_Avoid_: hard hook, mandatory guazi-flow coupling
