module Recipe exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Html exposing (..)
import Html.Attributes exposing (class, id)

-- MESSAGES
type Msg
    = FetchSuccess {recipes : (List Recipe)}
    | FetchFailure Http.Error

-- MODEL
type alias RecipeId =
    Int

type alias Recipe =
    { id : RecipeId
    , name : String
    , description : String
    }

type alias Model =
    { recipes : List Recipe
    , error   : Maybe String
    }

initialModel : Model
initialModel = Model [] (Nothing)

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ (showError model.error)
        , (showRecipes model.recipes)
        ]

showError : Maybe String -> Html Msg
showError x =
    case x of
        Just error -> div [] [ text error ]
        Nothing    -> div [] []

showRecipes : List Recipe -> Html Msg
showRecipes recipes =
    div [ class "grid" ] (List.map recipeRow recipes)

recipeRow : Recipe -> Html Msg
recipeRow recipe =
    div [ class "grid-item" ]
        [ div [ class "panel panel-default" ]
              [ div [ class "panel-heading" ]
                    [ p [ class "panel-title" ] [ text recipe.name ] ]
              , div [ class "panel-body" ] [ text recipe.description ]
              ]
        ]

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update message recipes =
    case message of
        FetchSuccess newRecipes ->
            (Model newRecipes.recipes (Nothing), Cmd.none)
        FetchFailure error ->
            (Model [] (Just (errorToString error)), Cmd.none)

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.Timeout             -> "Timeout"
        Http.NetworkError        -> "NetworkError"
        Http.UnexpectedPayload e -> "UnexpectedPayload: " ++ e
        Http.BadResponse code e  -> "BadResponse: " ++ (toString code) ++ " " ++ e

fetchAll : Cmd Msg
fetchAll =
    Http.get recipesDecoder "http://localhost:3000/recipe/"
        |> Task.perform FetchFailure FetchSuccess

type alias Recipes = { recipes : (List Recipe) }
              
recipesDecoder : Decode.Decoder Recipes
recipesDecoder =
    Decode.object1 Recipes ("recipes" := collectionDecoder)
              
collectionDecoder : Decode.Decoder (List Recipe)
collectionDecoder =
    Decode.list memberDecoder

memberDecoder : Decode.Decoder Recipe
memberDecoder =
    Decode.object3 Recipe
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)

