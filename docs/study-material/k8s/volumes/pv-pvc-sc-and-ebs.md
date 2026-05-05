Quick tests
For each: SC, PVC, PV, EBS — what happens?
Test 1. App is running normally. You delete a pod.
Test 2. App is running. You run kubectl delete pvc myclaim. Reclaim policy on the PV is Delete.
Test 3. Same as #2, but reclaim policy is Retain.
Test 4. You delete a StorageClass while a PVC is happily using it.
Test 5. You delete a PV while its PVC is still bound and the app is running.
Test 6. Reclaim policy is Retain. PVC gets deleted. A week later, you want the data back.
Test 7. PVC has storageClassName: ebs-gp3. You edit it to ebs-gp3-no-retain.

Answers
1. Pod dies, new pod starts, PVC/PV/EBS untouched. Data fine. (Pods are disposable, PVCs are not.)
2. PVC gone → PV auto-deleted → EBS volume auto-deleted. Data gone forever.
3. PVC gone → PV stays in Released state → EBS volume still in AWS. Orphan. (This is what created your 41 leftovers.)
4. Nothing happens to the running app. SC's job ended at provisioning time. The PVC and PV don't need it anymore. (But: a future new PVC asking for that SC will fail.)
5. Kubernetes blocks it. PVs with bound PVCs are protected. You'd have to delete the PVC first.
6. Possible! The PV is still there in Released state. You can manually create a new PVC and rebind it to that PV (it's a manual process — claimRef editing). Data recoverable.
7. Rejected. storageClassName is immutable.
