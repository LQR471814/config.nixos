#!/usr/bin/env nu

def "has user session" []: nothing -> bool {
  let sessions = (loginctl list-sessions --no-legend | lines)

  for row in $sessions {
    let sid = $row | parse "{name} {_}" | get name | first
    if ($sid | is-empty) {
      continue
    }

    let state = (loginctl show-session $sid -p State --value | str trim)
    let class = (loginctl show-session $sid -p Class --value | str trim)
    let remote = (loginctl show-session $sid -p Remote --value | str trim)

    if $state == active and $class == user and $remote == no {
      return true
    }
  }

  false
}

def "has tmux session" []: nothing -> bool {
  let result = (do --ignore-errors { tmux list-sessions } | complete)

  if $result.exit_code != 0 {
    return false
  }

  let sessions = $result.stdout
    | lines
    | where ($it | str trim) != ""

  ($sessions | length) > 0
}

if (has user session) {
  exit 0
}

if (has tmux session) {
  exit 0
}

exit 1
