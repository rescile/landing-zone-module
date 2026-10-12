local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = source.provider;
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='subscription',
  createFrom=rescile.createFromProperty('account', asName='account'),
  resourceType='account',
  relationType='BASELINE_TEMPLATE',
  name=parent + '-{{ value }}',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    environment: '{{- value | lower -}}',
    //template = "Core" # Only AWS
    provider: std.asciiLower(provider.name),
    service: provider.portfolio,
    regions: ['{{- origin_resource.home | capitalize -}}', 'London', 'Paris'],
    description: 'The ' + provider.name + ' ' + provider.decode.account + ' defines an independently manageable IAM security boundary for the {{ origin_resource.name | upper }} subscription that enables a centralized management and grants authorized access to resources, services and configurations.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
