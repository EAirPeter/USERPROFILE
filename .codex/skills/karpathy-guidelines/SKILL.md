---
name: karpathy-guidelines
description: "Apply Karpathy-style coding guardrails that reduce common LLM engineering mistakes. Use when writing, reviewing, debugging, or refactoring code to surface material assumptions and tradeoffs, prefer the simplest viable solution, define verifiable success criteria, and verify the result."
license: MIT
---

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Surface material assumptions, ambiguity, and tradeoffs before acting.**

- State assumptions that materially affect the implementation.
- If plausible interpretations would lead to different outcomes, present the alternatives instead of choosing silently.
- Explain meaningful tradeoffs and recommend a direction when useful.
- If important ambiguity remains after inspecting the available context, ask before proceeding.

## 2. Simplicity First

**Choose the simplest solution that fully meets the requirement.**

- Do not add features beyond what was requested.
- Avoid abstractions created for a single use unless they materially improve clarity.
- Do not introduce flexibility or configurability without a concrete need.
- Do not add defensive handling for scenarios ruled out by the known contracts or context.
- If a substantially simpler approach meets the same requirements, use it.

## 3. Goal-Driven Execution

**Define success criteria and keep working until the result is verified.**

- Convert the request into observable outcomes and relevant checks.
- For bugs, reproduce the failure before fixing it when practical.
- For refactors, verify behavior before and after the change.
- For multi-step work, pair each step with its verification.
- Run the relevant checks; if verification is blocked, explain why and state the remaining uncertainty.
