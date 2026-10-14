// empty.libsonnet — structural fallback for unknown providers and the
// engine's load-time mock. Values are placeholders: per-origin rules discard
// them, but every field a model touches must exist here or the load-time
// evaluation fails. Extend the decode list when models access new keys.
{
  title: 'Empty Library',
  version: '1.0',
  name: 'None',
  decode: {
    [t]: t
    for t in [
      'account',
      'connectivity',
      'compute',
      'database',
      'dns',
      'firewall',
      'gateway',
      'kubernetes',
      'load_balancer',
      'network',
      'record',
      'region',
      'resolver',
      'router',
      'storage',
      'subscription',
      'subnet',
      'key_management',
      'vpn',
      'wallet',
      'zone',
    ]
  },
  portfolio: [],
  roles: {},

  // Retrieve deduplicated permissions by service name
  getAdminPermissions(serviceName)::
    local matchingPermissions = [
      perm
      for roleKey in std.objectFields(self.roles)
      if std.get(self.roles[roleKey], 'service') == serviceName
      for perm in std.get(self.roles[roleKey], 'permissions', default=[])
    ];
    std.set(matchingPermissions),
}
