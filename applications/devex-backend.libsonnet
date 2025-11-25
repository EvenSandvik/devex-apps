function(
  env,
  version,
  name='devex-backend',
  clientId,
  secretStoreName='<SECRET_STORE_NAME>',
  esoName='devex-backend-secrets',
  gsmProjectId,
  databaseHost
) [
  {
    apiVersion: 'skiperator.kartverket.no/v1alpha1',
    kind: 'Application',
    metadata: {
      name: name,
    },
    spec: {
      image: version,
      port: 8080,
      liveness: {
        path: '/health',
        port: 8080,
      },
      readiness: {
        path: '/health',
        port: 8080,
      },
      ingresses: ['api.devex.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>'],
      resources: {
        requests: {
          cpu: '25m',
          memory: '256Mi',
        },
      },
      env: [
        {
          name: 'clientId',
          value: clientId,
        },
        {
          name: 'tenantId',
          value: '<TENANT_ID>',
        },
        {
          name: 'environment',
          value: 'production',
        },
        {
          name: 'skipEnv',
          value: env,
        },
        {
          name: 'DATABASE_USER',
          value: 'postgres',
        },
        {
          name: 'REGELRETT_URL',
          value: 'http://regelrett-backend.regelrett-main:8080',
        },
        {
          name: 'DATABASE_USERNAME',
          value: '<DATABASE_USERNAME>',
        },
        {
          name: 'ALLOWED_CORS_HOSTS',
          value: 'devex.<DOMAIN_PREFIX>-' + env + '.<DOMAIN_SUFFIX>',
        },

      ],
      envFrom: [
        {
          secret: esoName,
        },
      ],
      filesFrom: [
        {
          mountPath: '/app/db-ssl-ca',
          secret: 'db-ssl-ca',
        },
      ],
      accessPolicy: {
        inbound: {
          rules: [
            {
              application: 'devex-frontend',
            },
          ],
        },
        outbound: {
          rules: [
            {
              application: 'regelrett-backend',
            },
          ],
          external: [
            {
              host: '<MICROSOFT_LOGIN_HOST>',
            },
            {
              host: '<MICROSOFT_GRAPH_HOST>',
            },
            {
              host: '<DATABASE_HOST_NAME>',
              ip: databaseHost,
              ports: [
                {
                  name: 'sql',
                  port: 5432,
                  protocol: 'TCP',
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: esoName,
    },
    spec: {
      data: [
        {
          remoteRef: {
            key: 'devex-client-secret-backend',
            metadataPolicy: 'None',
          },
          secretKey: 'CLIENT_SECRET',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-private-ip',
            metadataPolicy: 'None',
          },
          secretKey: 'DATABASE_HOST',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-jdbc-url',
            metadataPolicy: 'None',
          },
          secretKey: 'JDBC_URL',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-admin-password',
            metadataPolicy: 'None',
          },
          secretKey: 'DATABASE_PASSWORD',
        },
      ],
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: secretStoreName,
      },
      target: {
        name: esoName,
      },
    },
  },
  {
    apiVersion: 'networking.istio.io/v1',
    kind: 'DestinationRule',
    metadata: {
      name: 'istio-sticky' + name,
    },
    spec: {
      host: name,
      trafficPolicy: {
        loadBalancer: {
          consistentHash: {
            httpCookie: {
              name: 'ISTIO-STICKY',
              path: '/',
              ttl: '0',
            },
          },
        },
      },
    },
  },
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'SecretStore',
    metadata: {
      name: secretStoreName,
    },
    spec: {
      provider: {
        gcpsm: {
          projectID: gsmProjectId,
        },
      },
    },
  },
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'db-ssl-ca',
    },
    spec: {
      data: [
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-ca-certificate',
            metadataPolicy: 'None',
          },
          secretKey: 'server-ca.pem',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-admin-client-certificate',
            metadataPolicy: 'None',
          },
          secretKey: 'client-cert.pem',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-admin-client-key',
            metadataPolicy: 'None',
          },
          secretKey: 'client-key.key',
        },
        {
          remoteRef: {
            key: 'cloudsql-devex-backend-db-admin-client-key-pk8',
            metadataPolicy: 'None',
          },
          secretKey: 'client-key.pk8',
        },
      ],
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: secretStoreName,
      },
      target: {
        name: 'db-ssl-ca',
      },
    },
  },
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'devex-backend-cloudsql',
      annotations: {
        'argocd.argoproj.io/sync-options': 'Prune=false',
      },
    },
    spec: {
      egress: [
        {
          ports: [
            {
              port: 5432,
              protocol: 'TCP',
            },
          ],
          to: [
            {
              ipBlock: {
                cidr: databaseHost + '/32',
              },
            },
          ],
        },
      ],
      podSelector: {
        matchExpressions: [
          {
            key: 'app',
            operator: 'In',
            values: ['devex-backend'],
          },
        ],
      },
      policyTypes: ['Egress'],
    },
  },
]