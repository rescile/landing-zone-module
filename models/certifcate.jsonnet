local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='wallet',
  createFrom=rescile.createFromProperty('certificate', asName='certificate'),
  resourceType= 'certificate',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-{{ value | lower }}-certificate',
  properties={
    class: '{{ value | lower }}',
    description: 'The {{ value | lower }} certificate verifies the identity of communicating endpoints and uses public key cryptography to encrypt data in transit, ensuring network traffic cannot be intercepted, modified, or tampered with.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
