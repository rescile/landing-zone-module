local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromProperty('compute', asName='compute'),
  resourceType='compute',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name) + '-' + provider.decode.compute + '-{{- value | lower -}}-instance',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['compute-administrator', 'auditor'],
    component: ["instance","fleet","access","pipeline"],
    description: 'Compute instances provided by ' + provider.name + ' are on-demand virtual machines that are managed through code, including access and inter-node communication relying on dynamic, short-lived IAM tokens and automated TLS certificates rather than static passwords.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'compute')]
)
