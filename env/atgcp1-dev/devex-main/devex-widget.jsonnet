local widget = import '../../../applications/widget.libsonnet';
local databases = import 'databases.libsonnet';
local image = import 'widget-version';

local ingress = 'widget.atkv3-dev.<INTERNAL_DOMAIN>';

widget(
  image=image,
  db_host=databases.widget.host,
  db_ip=databases.widget.ip,
) {
  spec+: {
    env: [
      {
        name: 'WIDGET_INGRESS',
        value: ingress,
      },
    ],
    ingresses: [
      ingress,
    ],
  },
}
