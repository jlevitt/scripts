.
    | del(._embedded.items[].sent)                                      # Python hardcodes to true, Go is null
    | del(._embedded.items[]._embedded.menu_item._embedded)             # Removed in 1.1
    | del(._embedded.items[]._embedded.menu_item.in_stock)              # Removed in 1.1

    | del(._embedded.voided_combos)                                     # New in go
    | del(._links.voided_combos)                                        # New in go

    # ticket_number -> number in 1.1
    | .number_tmp = (.number // .ticket_number)
    | del(.ticket_number, .number)
    | .number = .number_tmp
    | del(.number_tmp)

    | del(.totals.inclusive_tax)                                        # Not implemented in py
    | del(.totals.exclusive_tax)                                        # Not implemented in py

    | del(._links.subscriptions)                                        # TODO: Probably handled by PyAPI - test
    | del(._embedded.payments[].full_name)                              # Removed in 1.1
    | del(._embedded.revenue_center.default)                            # Removed in 1.1
    | del(.correlation)                                                 # Not added to go agent yet

