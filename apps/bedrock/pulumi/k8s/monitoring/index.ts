import * as k8s from '@pulumi/kubernetes';

export const namespace = new k8s.core.v1.Namespace('monitoring', {
  metadata: {
    name: 'monitoring',
  },
});
