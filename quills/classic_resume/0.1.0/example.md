---
QUILL: classic_resume@0.1.0

# Header
#==========
name: Jane Doe
contacts:
  - "mailto:jane@example.com"
  - "+1 (555) 555-5555"
  - San Francisco, CA
  - "https://janedoe.dev"

# Sections
#==========
experience:
  - role: Senior Software Engineer
    organization: Acme Corp.
    location: Remote
    dates: Jan 2023 — Present
    bullets:
      - Led migration of a 400 kLoC monolith to event-driven microservices, dropping p99 checkout latency from 1.8 s to 240 ms.
      - Designed a real-time pricing service handling 50 K req/s on a 6-node Kubernetes cluster.
      - Mentored 4 engineers; introduced trunk-based development and codified release practices.
  - role: Software Engineer
    organization: Globex Inc.
    location: New York, NY
    dates: Jun 2019 — Dec 2022
    bullets:
      - Built customer analytics dashboard serving 10 K+ daily users (React, FastAPI, ClickHouse).
      - Cut infrastructure spend 25 % via right-sizing, spot-instance migration, and aggressive caching.

education:
  - degree: "B.S. Computer Science, *summa cum laude*"
    school: State University
    location: Anytown, USA
    dates: 2015 — 2019

projects:
  - name: Quillmark
    url: "https://quillmark.dev"
    bullets:
      - Open-source markdown-to-PDF engine powered by Typst; 1.5 K GitHub stars, used in production by three commercial deployments.
  - name: pgwarp
    url: "https://github.com/jdoe/pgwarp"
    bullets:
      - Logical-replication-based zero-downtime Postgres major-version upgrade tool.

skill_columns: 2
skills:
  - { category: Languages, text: "Go, Python, TypeScript, Rust" }
  - { category: Frameworks, text: "FastAPI, Django, React, Next.js" }
  - { category: Infrastructure, text: "Kubernetes, AWS, Terraform, PostgreSQL, Kafka" }
  - { category: Tools, text: "Git, Docker, Bazel, Datadog" }

awards:
  - title: Engineering Excellence Award
    issuer: Acme Corp.
    date: "2024"
  - title: "Top 1% Reviewer, ICML"
    date: "2022"
---

Backend engineer with 6+ years building distributed systems for high-traffic
consumer products. Strong in Go, Python, and infrastructure-as-code; happiest
reducing latency tail and on-call load.
