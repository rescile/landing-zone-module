local aws = import 'aws.libsonnet';
local azure = import 'azure.libsonnet';
local oci = import 'oci.libsonnet';
local google = import 'google.libsonnet';
local empty = import 'empty.libsonnet';

function(name)
  if name == 'aws' then aws
  else if name == 'azure' then azure
  else if name == 'oci' then oci
  else if name == 'google' then google
  //else error 'Unsupported provider: ' + name
  else empty
