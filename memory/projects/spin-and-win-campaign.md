---
name: spin-and-win-campaign
type: project
description: Spin & Win lead-generation prize wheel — Next.js 14 + MongoDB Atlas, server-authoritative prize engine (800 prizes), admin dashboard with CSV export. Ownership unknown.
updated: 2026-09-27
last_verified: 2026-09-26
paths: [~/Desktop/claude-project/spin-and-win-campaign]
confirmed: inferred
sources:
  - ~/Desktop/claude-project/spin-and-win-campaign/README.md
  - .env.example (variable names only)
  - git log / status
---

# Spin & Win campaign

## Ownership
- Ownership / client: **unknown.**

## Current state (verified from files, 2026-09-26)
- Path: `~/Desktop/claude-project/spin-and-win-campaign`. Remote: `github.com/shourovsoron/Visionic-Spinner`. Branch `main`. **Working tree clean.**
- Stack: Next.js 14 (App Router), React 18, TypeScript, Tailwind, MongoDB Atlas plus Mongoose.
- **Routes:**
  - `/spin`: public campaign page; `/` redirects here.
  - `/dashboard` and `/dashboard/login`: admin area.
  - `POST /api/spin`: the only public write endpoint.
  - `/api/admin/*`: stats, participants (including bulk delete), export, inventory, login and logout.
- **Prize engine** (`lib/prizeEngine.ts`): each spin runs in one MongoDB transaction. It checks for an existing participant by email or phone, makes a weighted-random pick among prizes with stock left, does an atomic conditional decrement, then inserts the participant. There is no client-side randomness. The four prize quantities must sum to exactly 800; the prize types are flight ticket, t-shirt and two coupon tiers. Transactions need a replica-set cluster (every Atlas cluster is one).
- **Admin CSV export** columns start with `Full Name, Phone, Email, Customer Type, …`.
- **Secrets:** `MONGODB_URI`, `ADMIN_USERNAME`, `ADMIN_PASSWORD` and `ADMIN_SESSION_SECRET` are expected in `.env.local`, which exists but **was not opened**. Prize quantities are also set there.
- Seed inventory once with `npm run seed`; it refuses to touch an existing campaign.
- **Committed history:** 3 commits. 2026-09-15 "first commit" and "add full name"; 2026-09-18 "new feild added".

## Relationship to other projects
- The admin export feeds [[prize-spinner]]. The Prize Spinner README says the Spin & Win export "works as-is" as its participant CSV. This is supported by files in both repos.

## Inferred (not confirmed by Soron)
- The repo name "Visionic-Spinner" suggests a Visionic connection. **Not assumed.**
- Deployment status and URL are unknown, and so is whether the campaign has run.

## Open questions
- Who is the campaign for? Is it deployed or finished?

## Next actions
None assigned.
