module EventSource where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Network.HTTP.Types as H
import Prim.Row (class Union)

foreign import data EventSource :: Type 

newtype EventName = EventName String 

type Extensions = 
  ( httpsRejectUnauthorized :: Boolean  
  , withCredentials         :: Boolean 
  , headers                 :: Array H.Header
  , proxy                   :: String 
  )

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

createEventSource :: forall exts t. 
  Union exts t Extensions 
  => String 
  -> Maybe { | exts }
  -> EventSource
createEventSource url Nothing = _createEventSource url {}
createEventSource url (Just exts) = _createEventSource url exts

readyState :: EventSource -> Effect ReadyState
readyState evs = do
  state <- _readyState evs
  pure case state of
    0 -> CONNECTING
    1 -> OPEN
    _ -> CLOSED
    
addEventListener :: forall event. EventSource -> EventName -> (event -> Effect Unit) -> Effect Unit  
addEventListener evs (EventName en) = _addEventListener evs en

removeEventListener :: forall event. EventSource -> EventName -> (event -> Effect Unit) -> Effect Unit  
removeEventListener evs (EventName en) = _removeEventListener evs en

onOpen :: forall event. EventSource -> (event -> Effect Unit) -> Effect Unit 
onOpen = _onOpen 

onMessage :: forall event. EventSource -> (event -> Effect Unit) -> Effect Unit 
onMessage = _onMessage 

onError :: EventSource -> (EventSourceError -> Effect Unit) -> Effect Unit 
onError evs = _onError evs ConnectionClosedErr EventSourceErr

foreign import _createEventSource :: forall opts. String -> opts -> EventSource 
foreign import _readyState :: EventSource -> Effect Int  
foreign import _addEventListener :: forall event. EventSource -> String -> (event -> Effect Unit) -> Effect Unit 
foreign import _removeEventListener :: forall event. EventSource -> String -> (event -> Effect Unit) -> Effect Unit 
foreign import close :: EventSource -> Effect Unit  
foreign import _onOpen :: forall event. EventSource -> (event -> Effect Unit) -> Effect Unit 
foreign import _onMessage :: forall event. EventSource -> (event -> Effect Unit) -> Effect Unit 
foreign import _onError :: 
  EventSource 
  -> (String  -> EventSourceError) 
  -> (H.Status -> EventSourceError) 
  -> (EventSourceError -> Effect Unit) 
  -> Effect Unit 