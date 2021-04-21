.[]
    | walk(if type=="object" and ._embedded.option_sets != null then del(._embedded.option_sets) else . end)
    | walk(if type=="object" and has("barcodes") then .barcodes = [] else . end)

    # Items
    |     ._embedded.items[].sent = true                                      									# Python hardcodes to true, Go is null
    |     ._embedded.voided_items[].sent = true                                      									# Python hardcodes to true, Go is null

    # Service charges - Python doesn't embed, go is probably correct.
    | del(._embedded.service_charges[]._embedded)
    | del(._embedded.service_charges[]._links.service_charge)

