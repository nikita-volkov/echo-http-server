import qualified Network.HTTP.Types as HttpTypes
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import Prelude hiding (app)

main = do
  port <- loadRequiredEnv @Int "PORT"
  Warp.run port app

app :: Wai.Application
app request respond = do
  requestBody <- Wai.strictRequestBody request
  respond $ response requestBody
  where
    requestContentType = lookup "content-type" (Wai.requestHeaders request)
    response body = do
      Wai.responseLBS HttpTypes.ok200 headers body
      where
        headers =
          maybe [] (pure . ("content-type",)) requestContentType

loadRequiredEnv :: Read a => String -> IO a
loadRequiredEnv name = do
  env <- lookupEnv name
  case env of
    Nothing -> die $ "Required env var not found: " <> name
    Just env -> case readMaybe env of
      Nothing -> die $ "Failed to parse " <> name <> ". Input: " <> env
      Just res -> return res
