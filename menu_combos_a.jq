.
    | del(._links.price_levels)                                                                                                                 # Python is wrong
    | del(._embedded.item_groups[]._embedded.items[]._links.categories)                                                                         # Python is wrong
    | del(._embedded.item_groups[]._embedded.items[]._links.option_sets)                                                                        # Python is wrong
    | del(._embedded.item_groups[]._embedded.items[]._links.price_levels)                                                                       # Python is wrong
    |._embedded.item_groups[]._embedded.items[]._embedded.menu_item._links |= {menu_categories: .categories, option_sets, price_levels, self}   # Python is wrong
