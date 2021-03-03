sort_by(.id)
    | .[]
    | del(._links)
    | del(._embedded.item_groups[]._links)
    | del(._embedded.item_groups[]._embedded.items[]._embedded)
    | del(._embedded.item_groups[]._embedded.items[]._links)
    | (._embedded.item_groups[].id) |= split("-")[-1]
    | (._embedded.item_groups[]._embedded.items[].id) |= split("-")[-1]
