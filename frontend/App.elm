module App exposing (..)

import Html exposing (Html, div, text, ul, li, p, a)
import Html.App
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import String
import Navigation exposing (program)
import UrlParser exposing (Parser, (</>), format, int, oneOf, s, string)
import Routing exposing (..)
import RecipeList
import RecipeView
import RecipeModel exposing (RecipeId)


-- MODEL
type alias Model =
    { recipes : RecipeList.Model
    , recipe : RecipeView.Model
    , route : Page
    }

init : Result String Page -> ( Model, Cmd Msg )
init result =
    urlUpdate result initialModel

initialModel : Model
initialModel =
    { recipes = RecipeList.initialModel
    , recipe = RecipeView.initialModel
    , route = Home
    }


-- MESSAGES
type Msg
    = RecipeListMsg RecipeList.Msg
    | RecipeViewMsg RecipeView.Msg
    | GoHome


-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ showNavigation
        , div [ class "container" ]
            [ case model.route of
                Home ->
                    (Html.App.map RecipeListMsg (RecipeList.view model.recipes))

                Recipe _ ->
                    (Html.App.map RecipeViewMsg (RecipeView.view model.recipe))
            ]
        ]

showNavigation : Html Msg
showNavigation =
    div [ class "navbar navbar-default" ]
        [ div [ class "container" ]
            [ div [ class "navbarheader" ]
                [ a [ onClick GoHome ]
                    [ p [ class "navbar-brand" ] [ text "RecipeDB" ] ]
                ]
            ]
        ]



------------
-- UPDATE --
------------
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecipeListMsg (RecipeList.CreateRecipe) ->
            ( { model
                | route = Recipe -1
                , recipe = RecipeView.createNewModel
              }
            , Cmd.none
            )

        RecipeListMsg subMsg ->
            let
                ( newRecipes, cmd ) =
                    RecipeList.update subMsg model.recipes
            in
                ( { model | recipes = newRecipes }, Cmd.map RecipeListMsg cmd )

        RecipeViewMsg subMsg ->
            let
                ( newRecipe, cmd ) =
                    RecipeView.update subMsg model.recipe
            in
                ( { model | recipe = newRecipe }, Cmd.map RecipeViewMsg cmd )

        GoHome ->
            ( model, Navigation.modifyUrl (Routing.toHash Routing.Home) )



----------------
-- URL UPDATE --
----------------
urlUpdate : Result String Page -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    updatePage (Result.withDefault Home result) model

updatePage : Page -> Model -> ( Model, Cmd Msg )
updatePage page model =
    ( { model | route = page }
    , updatePageMessage page
    )

updatePageMessage : Page -> Cmd Msg
updatePageMessage page =
    case page of
        Home ->
            Cmd.map RecipeListMsg (RecipeList.fetchAll)

        Recipe id ->
            Cmd.map RecipeViewMsg (RecipeView.fetchRecipe id)

pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ format Home (s "")
        , format Recipe (s "recipe" </> int)
        ]

hashParser : Navigation.Location -> Result String Page
hashParser location =
    location.hash
        |> String.dropLeft 1
        |> UrlParser.parse identity pageParser


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- MAIN
main : Program Never
main =
    program
        (Navigation.makeParser hashParser)
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , view = view
        , subscriptions = subscriptions
        }
