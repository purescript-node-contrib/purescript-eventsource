module EventSource where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Foreign (Foreign)
import Network.HTTP.Types as H

foreign import data EventSource :: Type 

data ExtentionOptions 

httpsRejectUnauthorized :: Option ExtentionOptions Boolean 
httpsRejectUnauthorized = opt "httpsRejectUnauthorized"

withCredentials :: Option ExtentionOptions Boolean 
withCredentials = opt "withCredentials"

headers :: Option ExtentionOptions (Array H.Header)
headers = opt "headers"

proxy :: Option ExtentionOptions String 
proxy = opt "proxy"

newtype EventName = EventName String 

type MessageEvent = 
  { type        :: String 
  , data        :: String 
  , lastEventId :: String 
  , origin      :: String 
  }

data EventSourceError 
  = EventSourceErr H.Status
  | ConnectionClosedErr String 

-- | Connections states 
data ReadyState = CONNECTING
                | OPEN
                | CLOSED

derive instance genericReadyState :: Generic ReadyState _
derive instance eqReadyState :: Eq ReadyState

instance showReadyState :: Show ReadyState where
  show = genericShow

eventName :: String -> EventName 
eventName = EventName 

createEventSource :: String -> Options ExtentionOptions -> Effect EventSource
createEventSource url opts = _createEventSource url $ options opts

readyState :: EventSource -> Effect ReadyState
readyState evs = do
  state <- _readyState evs
  pure case state of
    0 -> CONNECTING
    1 -> OPEN
    _ -> CLOSED
    
addEventListener :: EventSource -> EventName -> (MessageEvent -> Effect Unit) -> Effect Unit  
addEventListener evs (EventName en) = _addEventListener evs en

removeEventListener :: EventSource -> EventName -> Effect Unit -> Effect Unit  
removeEventListener evs (EventName en) = _removeEventListener evs en

onOpen :: EventSource -> Effect Unit -> Effect Unit 
onOpen = _onOpen 

-- | This will only fire if your event name is 'message', do not use it unless so.
onMessage :: EventSource -> (MessageEvent -> Effect Unit) -> Effect Unit 
onMessage = _onMessage 

onError :: EventSource -> (EventSourceError -> Effect Unit) -> Effect Unit 
onError evs = _onError evs ConnectionClosedErr EventSourceErr

foreign import _createEventSource :: String -> Foreign -> Effect EventSource 
foreign import _readyState :: EventSource -> Effect Int 
foreign import _addEventListener :: EventSource -> String -> (MessageEvent -> Effect Unit) -> Effect Unit 
foreign import _removeEventListener :: EventSource -> String -> Effect Unit -> Effect Unit 
foreign import close :: EventSource -> Effect Unit  
foreign import _onOpen :: EventSource -> Effect Unit -> Effect Unit 
foreign import _onMessage :: EventSource -> (MessageEvent -> Effect Unit) -> Effect Unit
foreign import _onError :: 
  EventSource 
  -> (String  -> EventSourceError) 
  -> (H.Status -> EventSourceError) 
  -> (EventSourceError -> Effect Unit) 
  -> Effect Unit 