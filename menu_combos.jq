sort_by(.id)
    | .[]
    | del(._embedded.item_groups[]._links)                              # Python is wrong
    | del(._embedded.item_groups[]._embedded.items[]._links.self)       # Python is wrong
    | (._embedded.item_groups[].id) |= split("-")[-1]                   # ID change
    | (._embedded.item_groups[]._embedded.items[].id) |= split("-")[-1] # ID change
