local argokit = import '../argokit/jsonnet/argokit.libsonnet';

function(image, db_host, db_ip) {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'Application',
  metadata: {
    name: 'widget',
  },
  spec: {
    image: image,
    port: 5000,
    envFrom: [
      { secret: 'widget-db-secret' },
    ],
    resources: {
      limits: {
        memory: '2G',
      },
      requests: {
        cpu: '100m',
        memory: '256M',
      },
    },
    prometheus: {
      path: '/widget/v1/metrics',
      port: 5000,
    },
    accessPolicy: {
      outbound: {
        external: [
          {
            host: db_host,
            ip: db_ip,
            ports: [
              {
                name: 'psql',
                protocol: 'TCP',
                port: 5432,
              },
            ],
          },
        ],
      },
    },
    liveness: {
      path: '/widget/v1/healthx',
      port: 5000,
    },
    readiness: {
      path: '/widget/v1/healthz',
      port: 5000,
    },
  },
}
