module Util exposing (errorToString)

import Http

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.Timeout             -> "Timeout"
        Http.NetworkError        -> "NetworkError"
        Http.UnexpectedPayload e -> "UnexpectedPayload: " ++ e
        Http.BadResponse code e  -> "BadResponse: " ++ (toString code) ++ " " ++ e
