local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local class = std.asciiLower(source.class);

[
  rescile.createResource(
    origin='service',
    resourceType='role',
    relationType='RESPONSIBLE_FOR',
    name= '{{- origin_resource.class | lower -}}-administrator',
    properties={
      class: '{{- origin_resource.class | lower -}}',
      channel: '{{- params.channel -}}',
      permissions: provider.getAdminPermissions(class),
      description: 'The {{ origin_resource.class | capitalize }} role is an identity with specific permissions attached to it that can be assumed by any authorized entity—such as a user, a service, or an application—for a temporary period.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
    match=[rescile.neq('class', 'key_management')],
  ),
  rescile.createResource(
    origin='service',
    resourceType='role',
    relationType='RESPONSIBLE_FOR',
    name= 'vault-administrator',
    properties={
      class: '{{- origin_resource.class | lower -}}',
      channel: '{{- params.channel -}}',
      permissions: provider.getAdminPermissions('vault'),
      description: 'The {{ origin_resource.class | capitalize }} role is an identity with specific permissions attached to it that can be assumed by any authorized entity—such as a user, a service, or an application—for a temporary period.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
    match=[rescile.eq('class', 'key_management')],
  ),
  rescile.createResource(
    origin='service',
    resourceType='role',
    relationType='VERIFIED_BY',
    name= 'auditor',
    properties={
      class: 'compliance',
      channel: '{{- params.channel -}}',
      permissions: provider.getAdminPermissions('audit'),
      description: 'The auditor is a read-only security and compliance role that provides visibility into cloud environments without granting operational or administrative privileges. It enables internal or external assessors to inspect configurations, review access policies, and examine immutable event logs to verify compliance with regulatory standards and enterprise policies.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    }
  )
]
