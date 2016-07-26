module RecipeList exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Html exposing (..)
import Html.Attributes exposing (class, id, href)
import Html.Events exposing (onClick)

import RecipeModel exposing (RecipeId, Recipe, recipeDecoder)
import Util exposing (errorToString)

-- MESSAGES
type Msg
    = FetchSuccess {recipes : (List Recipe)}
    | FetchFailure Http.Error

-- MODEL
type alias Model =
    { recipes : List Recipe
    , error   : Maybe String
    }

initialModel : Model
initialModel = Model [] Nothing

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ (showError model.error)
        , (showCrud)
        , div [ class "row" ] [ showRecipes model.recipes ]
        ]

showError : Maybe String -> Html Msg
showError x =
    case x of
        Just error -> div [ class "panel panel-danger" ]
                      [ div [ class "panel-heading" ]
                            [ p [ class "panel-title" ] [ text "Error" ]
                            ]
                      , div [ class "panel-body" ]
                          [ p [] [ text error ]
                          , p [] [ i [] [ text "Try again later. " ] ]
                          ]
                      ]
        Nothing    -> div [] []

showCrud : Html Msg
showCrud = div [ class "row crud" ]
           [ div [ class "col-xs-2" ]
                 [ button [ href ""
                          , class "btn btn-sm btn-success"
                          ]
                       [ text "Add recipe" ]
                 ]
           ]
        
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


fetchAll : Cmd Msg
fetchAll =
    Http.get recipesDecoder "http://localhost:3000/recipe/"
        |> Task.perform FetchFailure FetchSuccess

type alias Recipes = { recipes : (List Recipe) }
              
recipesDecoder : Decode.Decoder Recipes
recipesDecoder =
    Decode.object1 Recipes ("recipes" := recipeListDecoder)
              
recipeListDecoder : Decode.Decoder (List Recipe)
recipeListDecoder =
    Decode.list recipeDecoder

