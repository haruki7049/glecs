# Todos

## Game loop
```gleam
pub fn main() -> Nil {
  new_world()
  |> add_player_to_world()
  |> game_loop(fn(world, dt) {
    world
    |> movement_system(dt)
    |> collision_system()
    |> render_system()
  })
}
```