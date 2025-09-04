import glecs.{add_entity, component, new_world}

pub type Position {
  Position
  PositionData(x: Int, y: Int)
}

pub type Velocity {
  Velocity(x: Int, y: Int)
}

pub fn main() -> Nil {
  new_world()
  |> add_entity()
  // meh, why do we need two types :(
  |> component(Position).set(PositionData(1, 2))
  // problem: ideally this would error because we want a `Position` value, not the constructor
  |> component(Position).set(Position)
  // ugly, using `Velocity(0,0)` as the component key is random and non-intuitive
  |> component(Velocity(0, 0)).set(Velocity(0, 0))
  // the ideal api, but causes type mismatch error
  |> component(Velocity).set(Velocity(0, 0))

  Nil
}
