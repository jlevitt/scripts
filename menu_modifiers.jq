._embedded.modifiers | sort_by(.id) | .[] | del(._embedded.option_sets) | del(._embedded.price_levels[].barcodes) | del(.barcodes)
