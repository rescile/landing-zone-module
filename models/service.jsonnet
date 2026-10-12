local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = source.provider;
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='account',
  createFrom=rescile.createFromProperty('service', asName='service'),
  resourceType='service',
  relationType='DEFINED_BY',
  name=std.asciiLower(provider.name)  + '-{{- value | lower -}}-service',
  properties={
    class: '{{- value | lower -}}',
    accounts: '{{ accounts }}',
    environment: '{{ origin_resource.environment }}',
    compute: '{{- params.compute_instances -}}',
    kubernetes: '{{- params.kubernetes_cluster -}}',
    database: '{{- params.database_instances -}}',
    description: 'The {{ value | lower }} service provides access to a platform operated by {{ origin_resource.provider | lower }}.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
) + {
  accounts: '{{ [x.account for x in origin_resource] | unique }}',
}
