# The Goal

Upload STIG scan results from a `.cklb` file into STIG Manager automatically using API calls and a bash script — no manual UI interaction.

# Step 1 — Auth (Keycloak)

Before anything else, you need a token. STIG Manager sits behind Keycloak, so every API call needs a Bearer token in the header. You already had a working `stigtoken` function that hits the Keycloak token endpoint using `client_credentials` (service account flow — no human login required). This part worked from day one.


# Step 2 — Finding the Right Import Endpoint

This is where most of the time went. We assumed there was a file upload endpoint like most similar tools have. We tried three different paths, all 404ing. The breakthrough was pulling the full API spec from the running instance:

```bash
curl -sk -H "Authorization: Bearer $ACCESS_TOKEN" \
  "$STIG_BASE/api/op/definition" | grep -i import
```

That returned nothing for reviews — meaning no file upload endpoint exists in this version. Reviews have to be posted as JSON.


# Step 3 — The Correct Flow

Once we knew there was no file upload, we figured out the real sequence:

1. Create a collection — a container/folder in STIG Manager
2. Create an asset — the specific host inside that collection
3. Pin the revision — tell STIG Manager which version of the benchmark applies
4. Parse the CKLB and POST reviews — read the file with jq, transform the data, send it as JSON


# Step 4 — Collection Creation Gotchas

First attempt at creating a collection failed because we were missing required fields. We discovered each one by reading the error the API returned. The non-obvious ones were:

- `description` must be present even if `null`
- `grants` must include the internal STIG Manager user ID (we got this from `GET /api/user`) — not the Keycloak UUID


# Step 5 — Asset Creation Gotchas

Same approach — tried it, read the errors, added the missing fields one by one. Required fields that weren't obvious: `description`, `ip`, `noncomputing`. Once those were all present it worked.


# Step 6 — The Version Mismatch Problem

This cost the most time. Your CKLB was generated against V1R1 of the benchmark. STIG Library only had V1R3. Every import attempt returned "not found" because STIG Manager was looking for V1R1 rule IDs and couldn't find them. Solution: your coworker loaded the V1R1 ZIP into the STIG Library, and then everything matched.


# Step 7 — The _rule Suffix

Once versions matched, reviews were being rejected with "no grant for this asset/ruleId." We queried what rule IDs STIG Manager actually had stored:

```bash
curl -sk ... "$STIG_BASE/api/stigs/Amazon_Linux_2023_STIG/revisions/V1R1/rules" | jq '.[0]'
```

The CKLB had `SV-273994r1119970`. STIG Manager stored `SV-273994r1119970_rule`. We added `+ "_rule"` to the jq parsing and the rejections stopped.


# Step 8 — Status Mapping

The CKLB uses its own status vocabulary. STIG Manager uses different words. Had to translate:
CKLB               STIG Manager
`not_a_finding`      `pass`
`not_applicable`     `notapplicable`
`open`               `fail`
anything else      `notchecked`


# Step 9 — First Successful Import

After all of the above: 192 reviews inserted, 0 rejected. Validated with:

```bash
curl -sk ... "$STIG_BASE/api/collections/6/reviews/6" | jq 'length'
# 192

curl -sk ... "$STIG_BASE/api/collections/6/metrics/summary/collection" | jq '.metrics.results'
# 168 pass, 15 N/A, 9 fail
```


# Step 10 — Script Hardening
The script was cleaned up so it:

- Fails loudly if asset creation fails (instead of silently continuing with a null ID)

- Accepts `-c` for existing collection, `-n` to create a new one, `-a` for a custom asset name

- Builds all JSON with `jq -n --arg` instead of shell string interpolation (prevents silent breakage on special characters)


The One-Sentence Summary

You wrote a bash script that reads a CKLB file, creates a collection and asset in STIG Manager via API, pins the correct STIG revision, translates and posts all 192 rule results as JSON — fully automated, no UI required.
