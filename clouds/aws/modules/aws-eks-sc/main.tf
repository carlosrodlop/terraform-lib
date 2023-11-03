locals {
  eks_efs_driver = trim(var.efs_id, " ") == "" ? false : true
}

resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  # This is true because the resources was already created by the ebs-csi-driver addon
  force = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    # IMPORTANT: Prometheus and Velero requires gp3 (Block Storage)
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = "true"
    fsType    = "ext4"
    type      = "gp3"
  }
}

resource "kubernetes_storage_class_v1" "efs" {
  count = local.eks_efs_driver ? 1 : 0
  metadata {
    name = "efs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
    #uid              = "1000" #For CloudBees CI and CD
  }

  mount_options = [
    "iam"
  ]
}
