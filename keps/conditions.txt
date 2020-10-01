------------

spec:
  init:
    waitForInitialRestore: true

------------

Conditions:

ProvisioningStarted -----> ReplicaReady ------> AcceptingConn ----> DataRestored ---------> Provisioned

ProvisioningStarted = True
Provisioned         = True
DataRestoreStarted  = True       <-------------------
DataRestored        = True       <-------------------
Ready               = True

Transitional conditions

ReplicaReady
AcceptingConn
Ready
DataRestored
Paused

------------

Phase:

Provisioning
DataRestoring
Running / Ready <----- DB / STS watcher

Critical <-------- STS watcher
NotReady
Halted

-----------
// operator 

func Run() {
	// AcceptingConn
	go wait.ImmediatePollInfinite(3*time.Min, func(){
		dbLister.(core.NamespaceAll).List("")


		return true
	})
}

// apimachinery helper

func PhaseFromConditions(conditions) {
	
}


---------------
// operator

func DBForSTS(kind string, s *apps.STS) (db_name) {
	ctrl := metav1.GetControllerOf(s)
	ok, err := core_util.IsOwnerOfGroupKind(ctrl, kubedb.GroupName, kind)
	if err != nil || !ok {
		return ""
	}
	return ctrl.Name
}

stsLister

stsInformer.AddEventHandler({
	Add / Update: func(old, new) {
	   db_name := DBForSTS("MySQL", new)
	   if db_name != "" {
	   		if new_is_NOT_ready {
	   		   db_UpdateStatus(db_name).cond[ReadyReplicas] = false
	   		} else {
	   		   all_sts_for_this_db = stsLister.Namespaces(ns).List(sel)
	   		   if all_sts_for_this_db is_ready {
	   		   		getDB(sel).cond[ReadyReplicas] = true
	   		   }
	   		}
	   }
	}
} )
