module Examples.Client where

import Prelude

import Effect (Effect)
import Effect.Class.Console as Console
import EventSource as ES

main :: Effect Unit
main = do 
  es <- ES.createEventSource "http://localhost:3000" mempty

  ES.onMessage es \me -> do 
    Console.log me.data 