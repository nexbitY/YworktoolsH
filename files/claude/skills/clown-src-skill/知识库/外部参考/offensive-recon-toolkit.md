---
name: offensive-recon-toolkit
description: "Reconnaissance tooling arsenal with concrete, copy-paste assets: Google dork corpus (9 categories + GitHub code-search templates), secret-detection regex catalog (cloud keys, VCS/CI tokens, payment/SaaS providers, AI API keys, private keys, JWTs), 9 read-only credential validators (Postman, AWS, GitHub, Slack, Anthropic, OpenAI, npm, Atlassian, DataDog), discovery path wordlists (Swagger/OpenAPI, GraphQL, always-on files, SAML, Kubernetes), cloud-bucket brute-force composition, subdomain-takeover fingerprints, and sector-specific modules (ICS/SCADA, healthcare, finance, IoT, government). Use at the start of a bug bounty / external pentest to build the attack-surface map, hunt leaked secrets, and enumerate exposed endpoints. Complements offensive-osint (methodology) with the actual strings and patterns."
---

# Recon Toolkit — Concrete Assets

`offensive-osint` answers *"how to think"*; this skill answers *"what to paste"*. Every asset here is a concrete string, regex, path, or template.

## Quick Workflow

1. Scope: confirm in-scope domains, wildcards, and exclusions before touching anything
2. Asset discovery: subdomains → live hosts → tech fingerprint → endpoint enumeration
3. Secret hunting: GitHub code search + JS bundle mining + public paste/CI artifacts
4. Validate any found secret **read-only** before reporting
5. Feed the surface map into the relevant `offensive-*` hunting skill

---

## 1. Google Dork Corpus

### Sensitive files & config
```
site:target.com ext:env | ext:yml | ext:yaml | ext:ini | ext:conf | ext:cfg
site:target.com inurl:".git" | inurl:".svn" | inurl:".DS_Store"
site:target.com ext:log | ext:bak | ext:old | ext:orig | ext:swp | ext:sql
site:target.com ext:pem | ext:key | ext:p12 | ext:pfx | ext:jks
site:target.com intitle:"index of" "parent directory"
```

### Exposed panels & admin
```
site:target.com inurl:admin | inurl:login | inurl:dashboard | inurl:portal
site:target.com inurl:phpmyadmin | inurl:adminer | inurl:wp-admin
site:target.com intitle:"Dashboard" | intitle:"phpMyAdmin" | intitle:"Grafana"
site:target.com inurl:"/actuator" | inurl:"/actuator/env" | inurl:"/actuator/heapdump"
site:target.com inurl:"/swagger-ui" | inurl:"/api-docs" | inurl:"/openapi.json"
```

### Documents, errors, third-party leaks
```
site:target.com ext:pdf | ext:docx | ext:xlsx | ext:pptx | ext:csv
site:target.com "sql syntax near" | "Warning: mysql_" | "ORA-01756"
site:pastebin.com "target.com"
site:trello.com "target.com" | site:s3.amazonaws.com "target.com"
site:*.target.com -www
```

### Cloud storage
```
site:s3.amazonaws.com "target"
site:blob.core.windows.net "target"
site:storage.googleapis.com "target"
site:digitaloceanspaces.com "target"
```

### GitHub code-search templates (run on github.com/search?type=code)
```
"target.com" password
"target.com" api_key OR apikey OR api-key
"target.com" secret OR token OR bearer
org:target filename:.env
org:target filename:config.json password
org:target "BEGIN RSA PRIVATE KEY"
org:target "AKIA"                       # AWS access key id prefix
org:target extension:tf "access_key"
```

---

## 2. Secret-Detection Regex Catalog

Run these over crawled JS bundles, GitHub search results, and public artifacts. Keep a **high-precision** core set to avoid false positives.

### Cloud provider keys
```
AWS Access Key ID      : AKIA[0-9A-Z]{16}
AWS Secret Access Key  : (?i)aws_secret[^0-9a-zA-Z]{0,5}[0-9a-zA-Z/+]{40}
AWS ARN (account id)   : arn:aws:[a-z0-9-]*:[a-z0-9-]*:[0-9]{12}:
GCP API key            : AIza[0-9A-Za-z\-_]{35}
GCP service account    : "type":\s*"service_account"
Azure storage key      : (?i)AccountKey=[A-Za-z0-9+/=]{88}
Azure SAS token        : sig=[A-Za-z0-9%]{43,}
```

### VCS / CI tokens
```
GitHub PAT (classic)   : gh[pousr]_[0-9A-Za-z]{36,255}
GitHub fine-grained    : github_pat_[0-9A-Za-z_]{82}
GitLab PAT             : glpat-[0-9A-Za-z\-_]{20}
npm token              : npm_[0-9A-Za-z]{36}
PyPI token             : pypi-AgEIcHlwaS5vcmc[A-Za-z0-9\-_]{50,}
Docker Hub PAT         : dckr_pat_[A-Za-z0-9\-_]{27}
Atlassian token        : ATATT3[A-Za-z0-9\-_=]{180,}
Slack token            : xox[baprs]-[0-9A-Za-z-]{10,72}
Slack webhook          : https://hooks\.slack\.com/services/T[0-9A-Za-z_]+/B[0-9A-Za-z_]+/[0-9A-Za-z]{24}
```

### Payment / SaaS / comms
```
Stripe live secret     : sk_live_[0-9a-zA-Z]{24,}
Stripe restricted      : rk_live_[0-9a-zA-Z]{24,}
Shopify access token   : shpat_[0-9a-fA-F]{32}
Shopify shared secret  : shpss_[0-9a-fA-F]{32}
SendGrid API key       : SG\.[A-Za-z0-9\-_]{22}\.[A-Za-z0-9\-_]{43}
Twilio SID             : AC[0-9a-fA-F]{32}
Mailgun key            : key-[0-9a-zA-Z]{32}
```

### AI / modern API keys
```
Anthropic              : sk-ant-[A-Za-z0-9\-_]{90,}
OpenAI                 : sk-[A-Za-z0-9]{20}T3BlbkFJ[A-Za-z0-9]{20}
OpenAI (project)       : sk-proj-[A-Za-z0-9\-_]{40,}
HuggingFace            : hf_[A-Za-z0-9]{34}
Cloudflare API token   : [A-Za-z0-9\-_]{40}   (context: "cloudflare" + "token")
```

### Generic high-signal
```
Private key block      : -----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----
JWT                    : eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}
Basic auth in URL      : [a-zA-Z]{3,10}://[^/\s:@]{3,20}:[^/\s:@]{3,20}@
Generic assignment     : (?i)(api[_-]?key|secret|passwd|password|token)\s*[:=]\s*["'][^"']{12,}["']
```

**Triage rule:** a regex hit is a *candidate*. Confirm it is live with a read-only validator (below) and confirm it is in scope before reporting.

---

## 3. Read-Only Credential Validators

Never use a found credential for anything but a **read-only identity check**. Nine high-value providers:

| Provider | Read-only check | Signal |
|----------|-----------------|--------|
| AWS | `aws sts get-caller-identity` | Account/ARN — proves key is live |
| GitHub | `GET /user` with the token | Login + scopes |
| Slack | `auth.test` | Team + user |
| npm | `GET /-/whoami` | Username |
| Postman | `GET /me` | User |
| Atlassian | `GET /myself` | Account |
| DataDog | `GET /api/v1/validate` | Validity |
| OpenAI | `GET /v1/models` | Key validity |
| Anthropic | minimal `messages` call | Key validity |

**Discipline:** identity check only → stop → report. Do not enumerate beyond what proves the finding, do not pivot, do not access customer data. See the scope rules in `offensive-reporting`.

---

## 4. Discovery Path Wordlists

### Swagger / OpenAPI (28 paths)
```
/swagger-ui.html /swagger-ui/ /swagger-ui/index.html /swagger/index.html
/swagger.json /swagger.yaml /openapi.json /openapi.yaml /api-docs /api-docs.json
/v2/api-docs /v3/api-docs /v3/api-docs/swagger-config
/redoc /docs /api/swagger /api/openapi.json /spec /api/spec
/actuator /actuator/mappings /actuator/env
```

### GraphQL (13 paths + introspection)
```
/graphql /graphiql /api/graphql /v1/graphql /query /gql /graphql/console
/graphql/v1 /api/v1/graphql /index.php?graphql /graphql.php /altair /playground
```
```json
{"query":"query IntrospectionQuery{__schema{types{name kind fields{name}}}}"}
```

### Always-on HTTP checks (15)
```
/.git/config /.git/HEAD /.svn/entries /.hg/store /.DS_Store
/.env /.env.local /.env.production /.env.backup
/robots.txt /sitemap.xml /crossdomain.xml /.well-known/security.txt
/backup.zip /db.sql /config.php.bak
```

### SAML metadata (5)
```
/saml/metadata /saml2/metadata /auth/saml/metadata /simplesaml/saml2/idp/metadata.php /Shibboleth.sso/Metadata
```

### Kubernetes / etcd / kubelet (12 ports + probes)
```
Ports: 6443 8080 10250 10255 10257 10259 2379 2380 4001 8081 8443 9090
Probes: /healthz /metrics /pods /version /api/v1/namespaces /api/v1/secrets
```

---

## 5. Cloud Bucket Brute-Force Composition

Enumerate `{prefix}-{stem}{suffix}` combinations:

- **Prefixes (6):** ``, `dev-`, `staging-`, `prod-`, `backup-`, `assets-`
- **Stems (47):** company name, brand, product names, common abbreviations
- **Suffixes (15):** ``, `-backup`, `-bak`, `-assets`, `-static`, `-media`, `-uploads`, `-data`, `-logs`, `-files`, `-public`, `-private`, `-dev`, `-test`, `-cdn`

Providers: `s3.amazonaws.com`, `storage.googleapis.com`, `blob.core.windows.net`.

**Verify ownership** before reporting: an open bucket that is not the target's is out of scope and a legal hazard. Check bucket contents/domain linkage for attribution.

---

## 6. Subdomain-Takeover Fingerprints

A dangling CNAME pointing at a de-provisioned service. Common providers to fingerprint: GitHub Pages, Heroku, AWS S3, AWS CloudFront, Azure (`*.azurewebsites.net`, `*.cloudapp.net`), Shopify, Zendesk, Fastly, Pantheon, Tumblr, WordPress, Netlify, Vercel, Surge.sh, Bitbucket, Cargo, Unbounce, UserVoice, Freshdesk, Readme.io, Statuspage, Ghost, Launchpad, Tilda, Helpjuice, Pingdom, Teamwork, SmugMug, Canny, Intercom.

**Method:** resolve CNAME → fetch the host → look for the provider's "no such app / not found" page → claim the resource in a sandbox → prove control → report with the takeover evidence.

---

## 7. Sector-Specific Modules

| Sector | Protocols / surfaces |
|--------|----------------------|
| ICS / SCADA | Modbus (502), BACnet (47808), Siemens S7 (102), DNP3 (20000), EtherNet/IP (44818) |
| Healthcare | DICOM (104/11112), HL7 v2 (MLLP), FHIR APIs, Epic/Cerner/Allscripts endpoints |
| Finance | SWIFT, FIX (9876/9878), Bloomberg, Temenos/Finacle/FIS/Fiserv |
| IoT | MQTT (1883/8883), CoAP (5683), UPnP/SSDP (1900), Hikvision/Dahua DVR |
| Government | `.gov`/`.mil`, FedRAMP, FISMA, CUI, SAM.gov |

(Protocol-level testing detail lives in `offensive-iot`; this module is the *discovery* view.)

---

## 8. Attack-Path Templates

When a raw asset is found, these are the common escalations to test:

1. Open S3 bucket → enumerate → find PII/keys → report as data exposure
2. `.git` exposed → `git-dump` → recover source → find secrets → test the app with source knowledge
3. Exposed `.env` → DB/API creds → connect read-only → prove access
4. Swagger exposed → enumerate all endpoints → find unauth admin routes
5. GraphQL introspection on → enumerate mutations → IDOR/authz bypass
6. Actuator `/env` open → read config → find internal hostnames/creds
7. JS bundle → hardcoded API key → read-only validate → report
8. Subdomain takeover → claim → serve a benign proof page → report
9. Dangling CNAME + SPA → host your own bundle → credential-harvest PoC (authorized only)
10. Open Jupyter/Spark UI → RCE potential → prove with `whoami` only
11. Exposed CI artifact → pipeline token → read repo list only
12. Public Docker registry → pull image → extract baked secrets
13. Leaked JWT → decode → check alg/claims → test authz
14. Exposed Kubernetes API → `version` + `pods` (read) → report
15. Prometheus/Grafana open → metrics leak → internal topology
16. Exposed Jenkins → `/script` (if auth bypass) → prove with `println`
17. Old backup `.sql` → schema + hashes → report exposure (no cracking beyond PoC)
18. WordPress `wp-json` user enum → username list → feed to auth testing
19. Exposed `.DS_Store` → directory listing → hidden paths
20. `crossdomain.xml` wildcard → Flash/legacy CSRF surface
21. Open redirect in `?next=` → chain to OAuth (see `offensive-oauth`)
22. Exposed SAML metadata → IdP config → SP confusion
23. Public Postman collection → API schema + sample tokens
24. Source map `.map` → reconstruct original TS → find hidden endpoints
25. Exposed Terraform state → cloud resource map + secrets
26. Public Slack webhook → post to your own channel as PoC (authorized)
27. Verbose stack trace → framework/version → map to known CVEs

---

## Key References

- ProjectDiscovery: `subfinder`, `httpx`, `nuclei`, `katana`
- `gau` / `waybackurls` — historical URL mining
- `trufflehog` / `gitleaks` — secret scanning
- `crt.sh` + `?O=` organization certificate search
- Public records: OpenCorporates, SEC EDGAR, Companies House, GSXT
- Only run against assets you own or are authorized to test.
