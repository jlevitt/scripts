sort_by(.id) | .[] | del(._embedded.modifiers[]._embedded.price_levels[].barcodes) | del(._embedded.modifiers[].barcodes) | setpath(["_embedded", "modifiers"]; ._embedded.modifiers | sort_by(.id))
