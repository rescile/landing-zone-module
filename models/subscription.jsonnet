local rescile = import 'rescile/v1/rescile.libsonnet';

rescile.createResource(
  origin='resident',
  resourceType='subscription',
  relationType='OWNED_BY',
  name='{{ params.provider | lower }}-{{ params.tenant | upper }}-{{ params.solution | upper }}',
  properties={
    provider: '{{ params.provider | lower }}',
    class: '{{- params.solution | lower -}}',
    home: '{{- params.hm | lower -}}',
    account: '{{- params.acc -}}',
    region: ['{{- params.hm | capitalize -}}', 'London', 'Paris'],
    util: ['vault', 'syslog'],
    logging: true,
    auditing: true,
    description: 'The subscription defines a cloud environment at {{ params.provider | capitalize }} that allows {{ params.tenant | capitalize }} to deploy the {{ params.solution | lower }} solution.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
