# Task board (fixture for context.sh tests)

`ID | STATE | project | title | next step | updated | blocked_on | needs`

## Open
- T-0101 | IN_PROGRESS | alpha | Build alpha dashboard | continue | 2026-09-20
- T-0102 | WAITING_FOR_SORON | alpha | Choose alpha hosting provider for the production deployment environment | ask Soron | 2026-09-20 | blocked_on: hosting decision | needs: A-0102
- T-0103 | BLOCKED | beta | Beta API credentials missing | wait | 2026-09-20 | blocked_on: access from the site owner | needs: "Who owns beta?"
- T-0104 | NEW | clone | Fixture clone task | start | 2026-09-20

## Completed
- T-0100 | COMPLETED | alpha | Old alpha work | evidence: fixture | 2026-09-01
