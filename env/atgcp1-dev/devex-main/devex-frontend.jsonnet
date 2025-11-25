local application = import '../../../applications/devex-frontend.libsonnet';
local version = import 'image-url-devex-frontend';

application(
    env='dev',
    version=version,
    VITE_CLIENT_ID='<VITE_CLIENT_ID>',
)