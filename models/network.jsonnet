local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromProperty('accounts', asName='network'),
  resourceType='network',
  relationType='DEPENDS_ON',
  name=std.asciiLower(provider.name) + '-{{- value | lower -}}-' + provider.getResource('network'),
  properties={
    class: '{{- origin_resource.class | lower -}}',
    segment: '{{- segments[property.index] -}}',
    firewall: '{{- params.fw -}}',
    subnet: '{{- params.subn -}}',
    gateway: '{{- params.gtw -}}',
    description: 'The {{- origin_resource.class | lower -}} network is an virtual, on-demand infrastructure that connects users and applications to computing resources like servers, storage, and software, all delivered over the internet.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'network')]
) + {
segments: '{{- params.net | lib(path="network.rhai", function="cidr_split_n", n= params.acc | length) | __rescile_safe_print -}}',
}
