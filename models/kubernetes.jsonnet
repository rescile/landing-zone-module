local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromProperty('kubernetes', asName='kubernetes'),
  resourceType='kubernetes',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-' + provider.decode.kubernetes + '-{{- value | lower -}}-cluster',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['kubernetes-administrator', 'auditor'],
    component: ["controlplane","dataplane"],
    description: 'A Kubernetes cluster provided by ' + provider.name + ' is a set of virtual or physical machines (nodes) configured to run containerized applications, where the cloud provider manages the underlying platform infrastructure.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'kubernetes')]
)
