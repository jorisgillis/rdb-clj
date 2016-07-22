module App exposing (..)

import Html exposing (Html, div, text)
import Html.App

import Recipe

-- Model
type alias Model =
    { recipes : List Recipe.Recipe
    , errors  : List String
    }

init : (Model, Cmd Msg)
init = (initialModel, Cmd.map RecipeMsg Recipe.fetchAll)

initialModel : Model
initialModel =
    { recipes = []
    , errors  = []
    }

-- MESSAGES
type Msg
    = RecipeMsg Recipe.Msg

-- VIEW
view : Model -> Html Msg
view model =
    Html.App.map RecipeMsg (Recipe.view model.recipes model.errors)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        RecipeMsg subMsg ->
            let (apiRecipes, cmd) =
                    Recipe.update subMsg model.recipes
            in
                case apiRecipes.recipes of
                    Just recipes -> (Model recipes [], Cmd.map RecipeMsg cmd )
                    Nothing      -> (Model [] [(Maybe.withDefault "ERROR" apiRecipes.error)],
                                          Cmd.map RecipeMsg cmd)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MAIN
main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

