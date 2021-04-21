.[]
#    | sort_by(.id)[]
    | del(._embedded.items[].sent)                                      									# Python hardcodes to true, Go is null
    | del(._embedded.combos[].sent)                                      									# Python hardcodes to true, Go is null
    | del(._embedded.combos[]._embedded.items[]._embedded.menu_item.barcodes)              					# Python sometimes includes, sometimes doesn't (hamburger vs soda or fries). No clue why, but Go is correct.

    | del(.totals.inclusive_tax)                                        									# Not implemented in py
    | del(.totals.exclusive_tax)                                        									# Not implemented in py

    | del(._links.subscriptions)                                        									# TODO: Probably handled by PyAPI - test
    | del(.correlation)                                                 									# Not added to go agent yet
