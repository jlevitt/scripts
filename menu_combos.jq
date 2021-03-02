sort_by(.id) | .[] | del(._embedded.item_groups[]._links) | del(._links) | (._embedded.item_groups[].id) |= split("-")[-1] | del(._embedded.item_groups[]._embedded)
