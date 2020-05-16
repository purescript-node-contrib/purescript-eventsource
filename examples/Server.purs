module Examples.Server where

import Prelude

import Control.Plus (empty)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console as Console
import Effect.Now as Effect
import Effect.Timer (clearInterval, setInterval)
import Node.HTTP as HTTP
import Node.Stream as Stream
import SSE as SSE
import SSE.Types (EventName(..), ServerEvent(..))

main :: Effect Unit
main = do 
  server <- HTTP.createServer \req res -> app req res 
  HTTP.listen server { backlog: Nothing, hostname: "localhost",port: 3000 } do 
    Console.log "listen on port 3000"
  where 
    app req res  = do 
      Console.log "New connection"
      let resStream = HTTP.responseAsStream res
      sseStream <- SSE.createSseStream req
      _ <- SSE.pipe sseStream resStream 
    
      intervalId <- setInterval 1000 do 
        let event = Just $ EventName "message"
        date <- Effect.nowDateTime 
        void $ SSE.write sseStream $ ServerEvent { data: show date, event, id: empty }

      Stream.onClose resStream do 
        Console.log "lost connection"
        clearInterval intervalId