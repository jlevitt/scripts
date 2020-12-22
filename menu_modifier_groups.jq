sort_by(.id) | .[] | setpath(["_embedded", "modifiers"]; ._embedded.modifiers | sort_by(.id))
