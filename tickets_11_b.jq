.[]
    | del(._embedded.voided_combos)                                     									# New in go
    | del(._links.voided_combos)                                        									# New in go
    | del(._embedded.service_charges[]._embedded)                                                           # Go is correct
    | del(._embedded.service_charges[]._links.service_charge)                                               # Go is correct
