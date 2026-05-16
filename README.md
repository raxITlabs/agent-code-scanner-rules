# agent-code-scanner-rules

Open ast-grep rule pack for scanning AI agent code. **29 rules across 7 components**, organized around two complementary frameworks:

- **Scope / Sign / Stop** (architectural shifts from the "Kill the God Agent" talk) — what kind of architectural failure each rule detects
- **MAESTRO 7-layer** (CSA Agentic AI Threat Modeling Framework) — what layer of the agent stack each rule covers

Grounded in published thinking from: Meta's Rule of Two, Simon Willison's Lethal Trifecta, DeepMind's CaMeL, AWS Cedar/AgentCore, Microsoft's "When prompts become shells", Tim Kellogg's MCP Colors, and the CSA MAESTRO framework.

Maintained by raxIT and consumed by the raxIT AI security scanner, but intentionally vendor-neutral so engineers can use the pack standalone with ast-grep.

## Repo structure

```
rules/
  agent/         General agent architecture rules
  identity/      Auth / capability / Confused Deputy rules (Sign)
  control-flow/  Reference monitor / composition rules (Stop)
  mcp/           MCP-specific patterns
  memory/        Memory architecture rules (Brooks's Dropbox pattern)
  skills/        Claude / Cursor skill rules
  gateway/       Gateway / middleware rules

fixtures/
  manifest.yaml  Test fixture corpus + expected findings per rule

scripts/
  run-fixtures.sh           Clone fixtures, run all rules, compare to expected
  validate-rules.sh         Lint rule YAML
  generate-manifest.py      Produce manifest.json for S3 upload
```

## How to use

### Run rules locally

```bash
# Install ast-grep (one-time)
brew install ast-grep

# Scan a directory
ast-grep scan --config sgconfig.yml /path/to/target

# JSON output
ast-grep scan --config sgconfig.yml --json /path/to/target
```

### Run against the fixture corpus

```bash
./scripts/run-fixtures.sh
```

This clones each fixture from `fixtures/manifest.yaml`, runs the full rule pack, and reports per-fixture findings vs expected.

### Add a new rule

1. Pick the right folder (`mcp/`, `memory/`, etc.)
2. Create `rule-name.yml` following the schema below
3. Add the rule to `fixtures/manifest.yaml` with expected output for at least one fixture
4. Run `./scripts/run-fixtures.sh` locally — should pass
5. Open PR

## Rule schema

```yaml
id: <component>.<rule-name>      # e.g., scope.rule-of-two-violation
language: python                  # or javascript, typescript, go
severity: error                   # error | warning | info
message: |-
  What the rule detected. Architectural fix: explain how to address.

metadata:
  shift: scope                    # scope | sign | stop  (Kill the God Agent framework)
  component: agent                # agent | identity | control-flow | mcp | memory | skills | gateway
  maestro_layer: L1               # L1-L7 (CSA MAESTRO framework, optional)
  framework: meta-rule-of-two     # source framework
  references:
    - https://ai.meta.com/blog/practical-ai-agent-security/

rule:
  # ast-grep pattern matcher
  pattern: ...
```

## Framework references

| Framework | URL |
|---|---|
| Meta Agents Rule of Two | https://ai.meta.com/blog/practical-ai-agent-security/ |
| Simon Willison — Lethal Trifecta | https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/ |
| DeepMind CaMeL | https://arxiv.org/abs/2503.18813 |
| CSA MAESTRO 7-layer Framework | https://cloudsecurityalliance.org/blog/2025/02/06/agentic-ai-threat-modeling-framework-maestro |
| Securing Agentic AI (paper applying MAESTRO) | https://arxiv.org/abs/2508.10043 |
| AWS Cedar / AgentCore | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-common-patterns.html |
| Microsoft — When prompts become shells | https://www.microsoft.com/en-us/security/blog/2026/05/07/prompts-become-shells-rce-vulnerabilities-ai-agent-frameworks/ |
| Tim Kellogg — MCP Colors | https://timkellogg.me/blog/2025/11/03/colors |

## Release flow

PR merged to `main` → GitHub Action validates → uploads to `s3://raxit-prod-scanner-rules/` → AgentCore scanners detect ETag change on next scan → new rules in effect within one scan window.

See [`docs/controls-platform/rule-registry-architecture-2026-05-16.html`](https://github.com/raxITlabs/raxit-app-cdk-v1) in the main app repo for full architecture.

## License

Proprietary — internal raxIT use. Rules can be redistributed under raxIT scanner output license.
