@if(!NoKargo)
package holos

Kargo: #Kargo & {
	Namespace: "kargo"

	// Holos specific kustomizations
	Values: #KargoValues & {
		// Istio handles mTLS for us.
		api: ingress: tls: enabled: false
		// Secret generated by the kargo-secrets holos component.
		api: secret: name: "admin-credentials"
	}

	// These values are specific to the k3d local demo environment and should be
	// changed for production.
	Values: {
		controller: serviceAccount: clusterWideSecretReadingEnabled: true
		controller: globalCredentials: namespaces: [Namespace]
	}
}

// Register namespaces and components with the project.
Projects: {
	argocd: {
		namespaces: (Kargo.Namespace): _
		components: {
			"rollouts-crds": {
				name: "rollouts-crds"
				path: "projects/argocd/components/rollouts-crds"
			}
			"rollouts": {
				name: "rollouts"
				path: "projects/argocd/components/rollouts"
			}
			"kargo-secrets": {
				name: "kargo-secrets"
				path: "projects/argocd/components/kargo-secrets"
			}
			"kargo": {
				name: "kargo"
				path: "projects/argocd/components/kargo"
			}
		}
	}
}
