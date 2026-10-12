local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local provider = providerLib('aws');

rescile.createResource(
  origin='resident',
  resourceType='subscription',
  relationType='OWNED_BY',
  name=std.asciiUpper(provider.name) + '-{{ params.tenant | upper }}-{{ params.solution | upper }}',
  properties={
    provider: std.asciiLower(provider.name),
    class: '{{- params.solution | lower -}}',
    home: '{{- params.hm | lower -}}',
    account: '{{- params.acc -}}',
    util: ['vault', 'syslog'],
    logging: true,
    auditing: true,
    description: 'The subscription defines a cloud environment at ' + provider.name + ' that allows {{ params.tenant | capitalize }} to deploy the {{ params.solution | lower }} solution.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
