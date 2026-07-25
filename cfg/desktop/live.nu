#!/usr/bin/env nu

def "has tmux session" []: nothing -> bool {
  let result = do --ignore-errors {
    tmux list-sessions | complete
  }

  if $result.exit_code? != 0 {
    return false
  }

  let sessions = $result.stdout
    | lines
    | where ($it | str trim) != ""

  ($sessions | length) > 0
}

if (has tmux session) {
  exit 0
}

exit 1
