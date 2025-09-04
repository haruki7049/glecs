import gleam/dynamic.{type Dynamic}

@external(erlang, "gleam_stdlib", "identity")
@external(javascript, "../../gleam_stdlib.mjs", "identity")
pub fn unsafe_coerce(value: a) -> b

@external(erlang, "gleam_stdlib", "identity")
@external(javascript, "../gleam_stdlib.mjs", "identity")
pub fn cast(a: anything) -> Dynamic
