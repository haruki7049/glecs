import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/list
import gleam/set.{type Set}

import unsafe_coerce.{cast, unsafe_coerce}

/// TODO: make opaque
pub type Entity {
  Entity(id: String)
}

pub opaque type World {
  World(
    entities: Set(Entity),
    components: Dict(dynamic.Dynamic, Dict(Entity, dynamic.Dynamic)),
  )
}

pub fn new_world() -> World {
  World(set.new(), dict.new())
}

pub fn add_entity(world: World) -> ComponentContext {
  // TODO: generate unique entity ID
  let entity = Entity(id: "entity_id")
  let World(entities, components) = world
  let updated_entities = set.insert(entities, entity)
  #(World(updated_entities, components), entity)
}

pub fn get_world(context: ComponentContext) -> World {
  let #(world, _) = context
  world
}

//------------

type ComponentContext =
  #(World, Entity)

pub type Component(data) {
  Component(
    set: fn(ComponentContext, data) -> ComponentContext,
    get: fn(ComponentContext) -> Result(data, Nil),
    delete: fn(ComponentContext) -> ComponentContext,
    has_entity: fn(ComponentContext) -> Bool,
    entities: fn(World) -> List(Entity),
    values: fn(World) -> List(data),
    to_list: fn(World) -> List(#(Entity, data)),
  )
}

/// Don't pay too much attention to the internal implementation right now (AI-assisted)
/// 
/// TODO: maybe add a second arg for a string serialization key?
pub fn component(key: data) -> Component(data) {
  let dynamic_key = cast(key)

  Component(
    set: fn(context: ComponentContext, value: data) -> ComponentContext {
      let #(world, entity) = context
      let World(entities, components) = world
      let entity_dict = case dict.get(components, dynamic_key) {
        Ok(existing) -> existing
        Error(_) -> dict.new()
      }
      let updated_entity_dict = dict.insert(entity_dict, entity, cast(value))
      let updated_components =
        dict.insert(components, dynamic_key, updated_entity_dict)
      #(World(entities, updated_components), entity)
    },
    get: fn(context: ComponentContext) -> Result(data, Nil) {
      let #(world, entity) = context
      let World(_, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> {
          case dict.get(entity_dict, entity) {
            Ok(dynamic_value) -> unsafe_coerce(dynamic_value) |> Ok
            Error(_) -> Error(Nil)
          }
        }
        Error(_) -> Error(Nil)
      }
    },
    delete: fn(context: ComponentContext) -> ComponentContext {
      let #(world, entity) = context
      let World(entities, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> {
          let updated_entity_dict = dict.delete(entity_dict, entity)
          let updated_components =
            dict.insert(components, dynamic_key, updated_entity_dict)
          #(World(entities, updated_components), entity)
        }
        Error(_) -> context
      }
    },
    has_entity: fn(context: ComponentContext) -> Bool {
      let #(world, entity) = context
      let World(_, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> dict.has_key(entity_dict, entity)
        Error(_) -> False
      }
    },
    entities: fn(world: World) -> List(Entity) {
      let World(_, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> dict.keys(entity_dict)
        Error(_) -> []
      }
    },
    values: fn(world: World) -> List(data) {
      let World(_, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> {
          dict.values(entity_dict)
          |> list.map(unsafe_coerce)
        }
        Error(_) -> []
      }
    },
    to_list: fn(world: World) -> List(#(Entity, data)) {
      let World(_, components) = world
      case dict.get(components, dynamic_key) {
        Ok(entity_dict) -> {
          dict.to_list(entity_dict)
          |> list.map(fn(pair) {
            let #(entity, dynamic_value) = pair
            #(entity, unsafe_coerce(dynamic_value))
          })
        }
        Error(_) -> []
      }
    },
  )
}
