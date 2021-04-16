.[]
    # Python is wrong
    | ._embedded.combos[]._embedded.items[]._embedded.menu_item._links |= (.menu_categories = .categories | del(.categories))
    | ._embedded.combos[]._embedded.menu_combo._links |= (.item_groups = .menu_combo_item_groups | del(.menu_combo_item_groups))

    | del(._embedded.items[]._embedded)                                 									# Removed in 1.1
    | del(._embedded.items[]._embedded.menu_item.in_stock)              									# Removed in 1.1

    | del(._embedded.combos[]._embedded.items[]._embedded.menu_item.in_stock)              					# Removed in 1.1
    | del(._embedded.combos[]._embedded.items[]._embedded.modifiers[]._embedded.menu_modifier._embedded)	# Removed in 1.1

    # ticket_number -> number in 1.1
    | .number = .ticket_number
    | del(.ticket_number)

    | del(._embedded.payments[].full_name)                              									# Removed in 1.1
    | del(._embedded.revenue_center.default)                            									# Removed in 1.1

    | del(._embedded.combos[]._embedded.menu_combo._links.price_levels)                                     # Not implemented in Go, maybe shouldn't be in python either.
