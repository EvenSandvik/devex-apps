function(name='devex-frontend', env, version, VITE_CLIENT_ID) [
  {
    apiVersion: 'skiperator.kartverket.no/v1alpha1',
    kind: 'Application',
    metadata: {
      name: name,
    },
    spec: {
      image: version,
      port: 3000,
      ingresses: ['devex.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>'],
      resources: {
        requests: {
          cpu: '25m',
          memory: '128Mi',
        },
      },
      accessPolicy: {
        outbound: {
          rules: [
            {
              application: 'devex-backend',
            },
          ],
          external: [
      {
         host: '<MICROSOFT_GRAPH_HOST>',
      },
      {
        host: '<MICROSOFT_LOGIN_HOST>',
      },
          ],
        },
      },
      env: [
        {
          name: 'VITE_CLIENT_ID',
          value: VITE_CLIENT_ID,
        },
        {
          name: 'VITE_AUTHORITY',
          value: 'https://login.microsoftonline.com/<TENANT_ID>',
        },
        {
          name: 'VITE_LOGIN_REDIRECT_URI',
          value: 'https://devex.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>',
        },
        {
          name: 'VITE_BACKEND_URL',
          value: 'https://api.devex.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>',
        },
        {
          name: 'VITE_REGELRETT_FRONTEND_URL',
          value: 'https://regelrett.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>',
        },
        {
          name: 'REGELRETT_CLIENT_ID',
          value: if env == 'dev' then '<REGELRETT_CLIENT_ID_DEV>'
          else if env == 'prod' then '<REGELRETT_CLIENT_ID_PROD>'
        },
      ],
    },
  },
]