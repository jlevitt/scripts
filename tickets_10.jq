.[]
    | del(._embedded.payments[].status)   # Don't care
    | ._embedded.items = (._embedded.items | sort_by(.id))
    | ._embedded.discounts = (._embedded.discounts | sort_by(.id))

    # Tempory - Hide missing menu items for combos, Python is right,
    | del(._embedded.items[]._links.menu_item)
    | del(._embedded.items[]._embedded.menu_item)

