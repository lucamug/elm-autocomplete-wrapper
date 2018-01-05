module Main exposing (main)

import Autocomplete
import AutocompleteWrapper
import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes


type alias Model =
    { field1 : AutocompleteWrapper.Model
    , field2 : AutocompleteWrapper.Model
    , field3 : AutocompleteWrapper.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { field1 = AutocompleteWrapper.init "id1" "State" menuItems1
      , field2 = AutocompleteWrapper.init "id2" "Language" menuItems2
      , field3 = AutocompleteWrapper.init "id3" "Color" menuItems3
      }
    , Cmd.none
    )


type Msg
    = OriginMessage String AutocompleteWrapper.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        msgConverter : Msg -> ( String, AutocompleteWrapper.Msg )
        msgConverter msg =
            case msg of
                OriginMessage id autocomMsg ->
                    ( id, autocomMsg )
    in
    case msg of
        OriginMessage id autocomMsg ->
            if id == model.field1.id then
                let
                    ( newModel, newMsg ) =
                        AutocompleteWrapper.update autocomMsg model.field1 OriginMessage msgConverter
                in
                { model | field1 = newModel } ! [ newMsg ]
            else if id == model.field2.id then
                let
                    ( newModel, newMsg ) =
                        AutocompleteWrapper.update autocomMsg model.field2 OriginMessage msgConverter
                in
                { model | field2 = newModel } ! [ newMsg ]
            else if id == model.field3.id then
                let
                    ( newModel, newMsg ) =
                        AutocompleteWrapper.update autocomMsg model.field3 OriginMessage msgConverter
                in
                { model | field3 = newModel } ! [ newMsg ]
            else
                model ! []



-- VIEWS


view : Model -> Html Msg
view model =
    div [ class "form-container" ]
        [ div [ style [ ( "text-align", "center" ) ] ]
            [ logoElm LightBlue "100px" "100px"
            , h1 [] [ text "Elm Autocomplete" ]
            , div []
                [ a [ href "https://medium.com/@l.mugnaini/autocomplete-widget-in-elm-4927b8e275db" ] [ text "Article" ]
                , text " ☀ "
                , a [ href "https://github.com/lucamug/elm-autocomplete-wrapper" ] [ text "Code" ]
                , text " ☀ "
                , a [ href "http://guupa.com/elm-autocomplete-wrapper/Example_Auto_4.html" ] [ text "Examples" ]
                ]
            , h2 [] [ text "Examples" ]
            ]
        , div
            []
            [ AutocompleteWrapper.view model.field1 OriginMessage
            , AutocompleteWrapper.view model.field2 OriginMessage
            , AutocompleteWrapper.view model.field3 OriginMessage
            ]
        , footer [] [ text "made with 凸 by ", a [ href "https://github.com/lucamug" ] [ text "lucamug" ] ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map (OriginMessage model.field1.id << AutocompleteWrapper.SetAutoState) Autocomplete.subscription
        , Sub.map (OriginMessage model.field2.id << AutocompleteWrapper.SetAutoState) Autocomplete.subscription
        , Sub.map (OriginMessage model.field3.id << AutocompleteWrapper.SetAutoState) Autocomplete.subscription
        ]



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MENU ITEMS


menuItems1 : List AutocompleteWrapper.MenuItem
menuItems1 =
    [ "Alabama"
    , "Alaska"
    , "Arizona"
    , "Arkansas"
    , "California"
    , "Colorado"
    , "Connecticut"
    , "Delaware"
    , "Florida"
    , "Georgia"
    , "Hawaii"
    , "Idaho"
    , "Illinois"
    , "Indiana"
    , "Iowa"
    , "Kansas"
    , "Kentucky"
    , "Louisiana"
    , "Maine"
    , "Maryland"
    , "Massachusetts"
    , "Michigan"
    , "Minnesota"
    , "Mississippi"
    , "Missouri"
    , "Montana"
    , "Nebraska"
    , "Nevada"
    , "New Hampshire"
    , "New Jersey"
    , "New Mexico"
    , "New York"
    , "North Carolina"
    , "North Dakota"
    , "Ohio"
    , "Oklahoma"
    , "Oregon"
    , "Pennsylvania"
    , "Rhode Island"
    , "South Carolina"
    , "South Dakota"
    , "Tennessee"
    , "Texas"
    , "Utah"
    , "Vermont"
    , "Virginia"
    , "Washington"
    , "West Virginia"
    , "Wisconsin"
    , "Wyoming"
    ]


menuItems2 : List AutocompleteWrapper.MenuItem
menuItems2 =
    [ "ABAP"
    , "ABC"
    , "ActionScript"
    , "Ada"
    , "Agilent VEE"
    , "Algol"
    , "Alice"
    , "Angelscript"
    , "Apex"
    , "APL"
    , "AppleScript"
    , "Arc"
    , "Arduino"
    , "ASP"
    , "AspectJ"
    , "Assembly"
    , "ATLAS"
    , "Augeas"
    , "AutoHotkey"
    , "AutoIt"
    , "AutoLISP"
    , "Automator"
    , "Avenue"
    , "Awk"
    , "Elm"
    ]


menuItems3 : List AutocompleteWrapper.MenuItem
menuItems3 =
    [ "Blue"
    , "Yellow"
    , "Red"
    , "Green"
    ]



-- SVG


type LogoColor
    = Colored
    | Orange
    | Green
    | LightBlue
    | Blue
    | White
    | Black


logoColor : LogoColor -> String
logoColor color =
    case color of
        Orange ->
            "#F0AD00"

        Green ->
            "#7FD13B"

        LightBlue ->
            "#60B5CC"

        Blue ->
            "#5A6378"

        _ ->
            "black"


logoElm : LogoColor -> String -> String -> Html msg
logoElm color x y =
    let
        f =
            Svg.Attributes.fill

        d =
            Svg.Attributes.d

        p =
            Svg.path

        orange =
            logoColor Orange

        green =
            logoColor Green

        lightBlue =
            logoColor LightBlue

        blue =
            logoColor Blue

        c =
            case color of
                Colored ->
                    { c1 = orange, c2 = green, c3 = lightBlue, c4 = blue }

                Orange ->
                    { c1 = orange, c2 = orange, c3 = orange, c4 = orange }

                Green ->
                    { c1 = green, c2 = green, c3 = green, c4 = green }

                LightBlue ->
                    { c1 = lightBlue, c2 = lightBlue, c3 = lightBlue, c4 = lightBlue }

                Blue ->
                    { c1 = blue, c2 = blue, c3 = blue, c4 = blue }

                White ->
                    { c1 = "white", c2 = "white", c3 = "white", c4 = "white" }

                Black ->
                    { c1 = "black", c2 = "black", c3 = "black", c4 = "black" }
    in
    Svg.svg
        [ Svg.Attributes.version "1"
        , Svg.Attributes.viewBox "0 0 323 323"
        , Svg.Attributes.width x
        , Svg.Attributes.height y
        ]
        [ p [ f c.c1, d "M162 153l70-70H92zm94 94l67 67V179z" ] []
        , p [ f c.c2, d "M9 0l70 70h153L162 0zm238 85l77 76-77 77-76-77z" ] []
        , p [ f c.c3, d "M323 144V0H180zm-161 27L9 323h305z" ] []
        , p [ f c.c4, d "M153 162L0 9v305z" ] []
        ]
