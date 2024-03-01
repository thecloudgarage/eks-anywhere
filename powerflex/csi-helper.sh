####REMOVE THE INIT SDC CONTAINER
sed -i '/^ *\initContainers:/{
:sub;
  $b eof;
  N;
/^\( *\)[^ ].*\n\1[^ ][^\n]*$/!b sub;
:eof;
  s/^\( *\)[^ ].*\n\(\1[^ ][^\n]*\)$/\2/;
  t loop;
  d;
:loop; n; b loop;
}' dell-helm-charts/charts/csi-vxflexos/templates/node.yaml
#
####ADD NODESELECTORS
sed -i '/nodeSelector:$/r'<(
echo "group: node-selector-group-name"
) ./dell-helm-charts/charts/csi-vxflexos/values.yaml
#
sed -i "s/^kubeVersion.*/kubeVersion: \"${eksdistroversion}\"/g" ./dell-helm-charts/charts/csi-vxflexos/Chart.yaml
#
