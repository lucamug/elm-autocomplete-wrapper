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
                OriginMessage fieldId autocomMsg ->
                    ( fieldId, autocomMsg )
    in
    case msg of
        OriginMessage fieldId autocomMsg ->
            if fieldId == model.field1.id then
                let
                    ( newModel, newMsg ) =
                        AutocompleteWrapper.update autocomMsg model.field1 OriginMessage msgConverter
                in
                { model | field1 = newModel } ! [ newMsg ]
            else if fieldId == model.field2.id then
                let
                    ( newModel, newMsg ) =
                        AutocompleteWrapper.update autocomMsg model.field2 OriginMessage msgConverter
                in
                { model | field2 = newModel } ! [ newMsg ]
            else if fieldId == model.field3.id then
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
            [ logoElm "100px" "100px"
            , h1 [] [ text "Elm Autocomplete" ]
            , p [] [ text "Examples" ]
            ]
        , div
            []
            [ AutocompleteWrapper.view model.field1 OriginMessage
            , AutocompleteWrapper.view model.field2 OriginMessage
            , AutocompleteWrapper.view model.field3 OriginMessage
            ]
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
-- blue #34485d


logoElm : String -> String -> Html msg
logoElm width height =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 323 323"
        , Svg.Attributes.width width
        , Svg.Attributes.height height
        ]
        [ Svg.path [ Svg.Attributes.fill "#F0AD00", Svg.Attributes.d "M162 153l70-70H92z" ] []
        , Svg.path [ Svg.Attributes.fill "#F0AD00", Svg.Attributes.d "M162 153l70-70H92z" ] []
        , Svg.path [ Svg.Attributes.fill "#7FD13B", Svg.Attributes.d "M9 0l70 70h153L162 0zm238 85l77 76-77 77-76-77z" ] []
        , Svg.path [ Svg.Attributes.fill "#60B5CC", Svg.Attributes.d "M323 144V0H180z" ] []
        , Svg.path [ Svg.Attributes.fill "#5A6378", Svg.Attributes.d "M153 162L0 9v305z" ] []
        , Svg.path [ Svg.Attributes.fill "#F0AD00", Svg.Attributes.d "M256 247l67 67V179z" ] []
        , Svg.path [ Svg.Attributes.fill "#60B5CC", Svg.Attributes.d "M162 171L9 323h305z" ] []
        ]
