.[]
    | select(.id != "4132580577281" and .id != "4132580577286" and .id != "4132578527233" and .id != "4132553314306" and .id != "4132553314305" and .id != "4132547069953" and .id != "4132530292737" and .id != "4132530245634" and .id != "4132530245633" and .id != "4132519759873" and .id != "4132517709825" and .id != "4132515565569")
    | del(._embedded.payments[].status)   # Don't care
    | ._embedded.items = (._embedded.items | sort_by(.id))
    | ._embedded.discounts = (._embedded.discounts | sort_by(.id))

