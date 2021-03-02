sort_by(.id) | .[] | del(._embedded.item_groups[]._embedded) | del(._embedded.item_groups[]._links) | del(._links) | setpath(["id"]; .id | split("-")[-1])
