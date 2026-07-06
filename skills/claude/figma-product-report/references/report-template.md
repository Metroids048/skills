# Product Report Template

Use this template when turning a Figma prototype into a product-manager-facing report.

## 1. Executive Conclusion

State what the product is, what it is not, who it serves, and the most important product judgement.

Good pattern:

```text
This product should be understood as [product category] for [target users/scenarios], not merely [surface-level UI interpretation]. Its core value is [business value loop]. The current prototype already covers [covered modules], but needs to strengthen [missing product logic].
```

## 2. Product Positioning

Include:

- Product category
- Target business domain
- Primary users
- Core capability set
- One-sentence stakeholder explanation

## 3. Users and Jobs-To-Be-Done

Use a table:

| User | Jobs | Pain Points | Product Value |
|---|---|---|---|
| Frontline user | Complete business task | Manual, slow, error-prone | Faster and safer completion |
| Expert | Review/correct/label | Expertise hard to scale | Experience becomes reusable |
| Operator | Manage quality and cost | Hard to see AI performance | Operational visibility |
| Admin/developer | Govern/build AI capability | Risk and resource complexity | Controlled enablement |

## 4. Product Architecture

Recommended layers:

- User entrance layer
- Business agent layer
- Agent development layer
- Model and data layer
- Expert/operations layer
- Governance/security layer

Use Mermaid if helpful.

## 5. Core Product Loop

For AI platforms, prefer:

```text
Business use -> user feedback -> expert handling -> high-quality sample/badcase -> knowledge/model/agent optimization -> release -> continued business use
```

Explain why this makes the product operational rather than demo-only.

## 6. Business Scenario Analysis

For each business scenario:

1. Scenario positioning
2. Current business pain
3. Product goal
4. Main functions
5. Inputs/rules/outputs
6. Main workflow
7. Current prototype coverage
8. Missing requirements and recommendations

Use tables for function scope:

| Capability | Product Requirement | Notes |
|---|---|---|
| Intelligent scheduling | Generate multiple plans based on constraints | Explain reasons and tradeoffs |
| Conflict detection | Detect resource/time/safety conflicts | Explain cause and resolution |

## 7. Platform Module Requirements

Recommended modules:

- Agent center
- Conversation/task execution
- Agent development
- Model service
- Dataset management
- Knowledge base
- Fine-tuning center
- Expert workbench
- Feedback center
- Operations dashboard
- Permission and developer management

For each module, cover:

- Target user
- Core functions
- Key object states
- Dependencies
- Gaps

## 8. Interaction and State Model

Include object states only for relevant objects:

| Object | Suggested States |
|---|---|
| Agent | draft, debugging, pending review, published, rejected, disabled |
| Feedback | pending, processing, waiting for expert, fixed, closed |
| Expert task | unclaimed, claimed, in progress, pending review, completed, overdue |

## 9. Permissions and Governance

For enterprise AI products, include:

- User -> role -> permission -> resource -> quota -> audit
- Functional permissions
- Data permissions
- Resource permissions
- Token/API quotas
- Over-limit strategy
- Developer certification
- API Key management
- Application release review
- Operation/model/security logs

## 10. Current Coverage and Gaps

Avoid raw Figma page names. Use product categories:

| Product Area | Covered | Gaps |
|---|---|---|
| User entrance | Login, homepage, chat | Missing task-oriented navigation |
| Agent center | Marketplace, personal agents | Missing lifecycle and review |
| Business scenario | Scenario entry exists | Missing complete workflow |

## 11. MVP Scope

Use P0/P1/P2:

- P0: end-to-end value loop and 1-2 flagship scenarios.
- P1: scenario expansion, data governance, expert workflow depth.
- P2: advanced orchestration, ecosystem, ROI optimization, compliance maturity.

## 12. Final Recommendation

End with a product judgement:

- What to build first
- What not to overbuild too early
- What must be clarified with stakeholders
- What prototype restructuring is recommended

