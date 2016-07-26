module App exposing (..)

import Html exposing (Html, div, text, ul, li, p)
import Html.App
import Html.Attributes exposing (class)

import RecipeList
import RecipeView

-- Model
type alias Model =
    { recipes : RecipeList.Model
    , recipe : RecipeView.Model
    }

init : (Model, Cmd Msg)
init = (initialModel, Cmd.map RecipeListMsg RecipeList.fetchAll)

initialModel : Model
initialModel =
    { recipes = RecipeList.initialModel
    , recipe = RecipeView.initialModel
    }

-- MESSAGES
type Msg
    = RecipeListMsg RecipeList.Msg
    | RecipeViewMsg RecipeView.Msg

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ showNavigation
        , div [ class "container" ]
              [ (Html.App.map RecipeListMsg (RecipeList.view model.recipes)) ]
        ]

showNavigation : Html Msg
showNavigation =
    div [ class "navbar navbar-default" ]
        [ div [class "container"]
              [ div [ class "navbarheader" ]
                    [ p [ class "navbar-brand" ] [ text "RecipeDB" ] ] ]
        ]

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        RecipeListMsg subMsg ->
            let (newRecipes, cmd) =
                    RecipeList.update subMsg model.recipes
            in
                ( { model | recipes = newRecipes }, Cmd.map RecipeListMsg cmd )
        RecipeViewMsg subMsg ->
            let (newRecipe, cmd) =
                    RecipeView.update subMsg model.recipe
            in
                ( { model | recipe = newRecipe }, Cmd.map RecipeViewMsg cmd )
                
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

