module Main exposing (main)

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Input
import Html
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


-- http://package.elm-lang.org/packages/mdgriffith/style-elements/4.2.1/Element-Input#autocomplete


type Styles
    = None
    | Page
    | Field
    | SubMenu
    | Flave


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Page
            [ Color.text Color.darkCharcoal
            , Color.background Color.white
            , Font.typeface
                [ Font.font "helvetica"
                , Font.font "arial"
                , Font.font "sans-serif"
                ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style Field
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.lightGrey
            ]
        , style SubMenu
            [ Border.rounded 5
            , Border.all 2
            , Border.solid
            , Color.border Color.grey
            ]
        ]


type alias Model =
    { search : Element.Input.SelectWith String Msg
    }


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( { search = Element.Input.autocomplete Nothing Search
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Search (Element.Input.SelectMsg String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        Search searchMsg ->
            let
                search =
                    Element.Input.updateSelection searchMsg model.search
            in
            ( { model | search = search }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    Element.layout stylesheet <|
        el None [ spacing 20, center, width (px 320) ] <|
            column Page
                [ spacing 20 ]
                [ h1 None [] <| text "Autocompete with Style Elements"
                , Element.Input.select Field
                    [ padding 10
                    , spacing 0
                    ]
                    { label = Element.Input.hiddenLabel "American State"
                    , with = model.search
                    , options = []
                    , max = 50
                    , menu =
                        Element.Input.menu SubMenu
                            []
                            (List.map
                                (\item -> Element.Input.choice item (text item))
                                menuItems1
                            )
                    }
                ]


menuItems1 : List String
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
