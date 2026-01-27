# Spotify Playlist Export via zsh (Verified End-to-End Steps)

This document records the exact steps used to:
- Acquire a Spotify access token
- Verify it works from the terminal
- Export playlist track data (Artist - Song)
- Handle pagination
- Write the output to a text file

All steps below reflect actions that were actually performed and verified
during the interactive session.

---

## Step 1 — Acquire a Spotify access token

A Spotify access token was obtained by logging into
https://developer.spotify.com/dashboard and re-authenticating.

During troubleshooting, logging out and back in resulted in a
newly issued access token.

This token was observed in JavaScript form as:
`const token = '...'`

(The token itself was not reused and was rotated.)

---

## Step 2 — Export the access token into the zsh environment

The token was manually exported into the shell using:

```bash
export SPOTIFY_TOKEN='PASTE_ACCESS_TOKEN_HERE'
```

---

## Step 3 — Verify the token is set in the environment

Verification command run:

```bash
echo ${SPOTIFY_TOKEN:+TOKEN_SET} ${#SPOTIFY_TOKEN}
```

Verified output:
`TOKEN_SET 101`

This confirmed:
- The variable exists
- The token is non-empty

---

## Step 4 — Verify the token is valid with the Spotify API

Run the command to verify access

```bash
curl -sS -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  https://api.spotify.com/v1/me | jq
```

Verified successful response:

```json
{
  "display_name": "USERNAME",
  "id": "USERNAME",
  "type": "user",
  "uri": "spotify:user:USERNAME"
}
```

This confirmed:
- The token is valid
- The Spotify user ID is `USERNAME`

---

## Step 5 — List playlists and obtain Playlist IDs

Playlist listing command used:

```bash
curl -sS -H "Authorization: Bearer $SPOTIFY_TOKEN" \
  "https://api.spotify.com/v1/me/playlists?limit=50" \
| jq -r '.items[] | "\(.name)\t\(.id)"'
```

From this output, the desired playlist ID was selected manually
and stored in a variable:

```bash
PLAYLIST_ID="PASTE_PLAYLIST_ID_HERE"
```

---

## Step 6 — Define the pagination-safe export function

The following function was pasted directly into the terminal
to handle Spotify’s 100-track pagination limit:

```bash
spotify_playlist_export () {
  emulate -L zsh
  setopt localoptions noxtrace

  local playlist_id="$1"
  local url="https://api.spotify.com/v1/playlists/${playlist_id}/tracks?limit=100&fields=items(track(name,artists(name))),next"

  while [[ -n "$url" && "$url" != "null" ]]; do
    local json
    json="$(curl -fsS -H "Authorization: Bearer $SPOTIFY_TOKEN" "$url")" || return 1

    echo "$json" | jq -r '.items[].track
      | select(. != null)
      | "\([.artists[].name] | join(", ")) - \(.name)"'

    url="$(echo "$json" | jq -r '.next')"
  done
}
```

This function was confirmed to iterate through multiple offsets
(0, 100, 200, 300).

---

## Step 7 — Export playlist tracks to a text file

The export was executed using:

```bash
spotify_playlist_export "$PLAYLIST_ID" > playlist.txt
```

---

## Step 8 — Verify exported line count

Verification command run:

```bash
wc -l playlist.txt
```

Verified output:
`335`

This indicated:
- All pages were fetched
- Extra lines were present

---

## Step 9 — Identify and remove debug output lines

Inspection of the file showed unexpected lines beginning with:
`json='{"items": ... }'`

These were identified as shell debug/xtrace artifacts
captured during pagination.

Manual cleanup was performed by removing those lines from the file.

(Automated cleanup could also be done with grep if needed.)

---

## Final Result

`playlist.txt` contains one song per line in the format:

`Artist1, Artist2 - Track Name`

Example verified entries:
`Morgan Wallen, ERNEST - Cowgirls (feat. ERNEST)`
`Luke Combs - Fast Car`
`Warren Zeiders - Pretty Little Poison`

---

## Re-run Summary

For future exports:
1. Re-authenticate to get a fresh token
2. `export SPOTIFY_TOKEN='...'`
3. Verify with `/v1/me`
4. Set `PLAYLIST_ID`
5. Run `spotify_playlist_export "$PLAYLIST_ID" > playlist.txt`

---
