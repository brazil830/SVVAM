# Acceptance checklist - Person 4 - AWS/QA/integration (Common PRD section 10)

- [ ] AWS services are feature-flagged and optional.
- [ ] Region/access/quotas are checked before use.
- [ ] AWS and 9Router costs are tracked separately.
- [ ] Integration test covers plan → approval → action → verification.
- [ ] Negative tests and test results are recorded.
- [ ] No expensive resource is provisioned without owner approval.

## Whole product

- [ ] One supported task completes and is verified.
- [ ] One unsafe or unsupported action is blocked.
- [ ] One failure/cancellation path is demonstrated.
- [ ] No arbitrary shell execution is exposed to the LLM.
- [ ] No credential/MFA automation exists.
- [ ] No secrets are committed.
- [ ] No claim of perfect or universal app control is made.
- [ ] Known limitations are written down.
