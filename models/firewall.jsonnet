local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiLower(std.join('-', std.slice(std.split(source.name, '-'), 0, 2)));

rescile.createResource(
  origin='network',
  createFrom=rescile.createFromProperty('firewall', asName='firewall'),
  resourceType='firewall',
  relationType='DERIVED_FROM',
  name=parent + '-{{ value }}-' + provider.getResource('firewall'),
  properties={
    class: '{% if value == "internet" %}public{% else %}private{% endif %}',
    filter: '{% if value == "internet" %}[{{- filters["https-tcp-egress"] -}}, {{- filters["https-tcp-ingress"] -}}]{% else %}[{{- filters["unrestricted-tcp-egress"] -}}, {{- filters["dns-udp-ingress"] -}}, {{- filters["dns-tcp-ingress"] -}}]{% endif %}',
    description: 'The {{ value }} firewall controls incoming (inbound) and outgoing (outbound) network traffic at the instance level.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
) + {
  filters: import 'firewall-rules.json',
}
