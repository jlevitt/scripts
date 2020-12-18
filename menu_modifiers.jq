sort_by(.id) | .[] | del(._embedded.price_levels[].barcodes) | del(.barcodes)
