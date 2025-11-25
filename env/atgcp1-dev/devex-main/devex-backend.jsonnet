local application = import '../../../applications/devex-backend.libsonnet';
local version = import 'image-url-devex-backend';

application(
    env='dev',
    version=version,
    clientId='<CLIENT_ID>',
    gsmProjectId='<GSM_PROJECT_ID>',
    databaseHost='<DATABASE_HOST>',
)