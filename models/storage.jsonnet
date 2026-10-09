local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

local instances = ['file'];

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromList('instances'),
  resourceType='storage',
  relationType='DEFINED_BY',
  name= std.asciiLower(provider.name) + '-{{ value | lower }}-' + provider.decode.storage + '-instance',
  properties={
    class: 'storage',
    login: ['storage-administrator', 'auditor'],
    component: ["object","block","file","backup"],
    description: 'A ' + provider.decode.storage + ' instance provided by ' + provider.name + ' is ranging from files and media to unstructured database objects and disk images—is transmitted and stored on remote storage systems. Instead of saving data to local hard drives or on-premises storage arrays, users access and manage data over the internet or private network connections via APIs, web consoles, or network protocols.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'storage')],
) + {
  instances: instances,
}
