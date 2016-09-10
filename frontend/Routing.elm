module Routing exposing (..)

import RecipeModel exposing (RecipeId)

type Page = Home | Recipe RecipeId

toHash : Page -> String
toHash page =
    case page of
        Home -> "#"
        Recipe id -> "#recipe/" ++ (toString id)

