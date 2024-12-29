@extern(embed)
package platform

import "example.com/holos/pkg/types/platform"

// stacks represents the software stacks managed in the platform.  Useful to
// iterate over all stacks to compose their components into a Platform.spec.
stacks: #Stacks & {
	argocd: (#StackBuilder & {
		parameters: {
			name: "argocd"
		}
		stack: namespaces: argocd: _
	}).stack

	security: (#StackBuilder & {
		parameters: {
			name: "security"
			components: {
				namespaces: {
					path: "stacks/security/components/namespaces"
					annotations: description: "configures namespaces for all stacks"
				}
			}
		}
	}).stack
}

// constrain the platform types
#Stacks: platform.#Stacks & {[_]: #Stack}
#Stack: platform.#Stack

#StackBuilder: {
	parameters: {
		name:       platform.#Name
		components: platform.#Components
	}
	stack: #Stack & {
		metadata: name: parameters.name

		for KEY, COMPONENT in parameters.components {
			components: "stacks:\(metadata.name):components:\(KEY)": COMPONENT & {
				name: KEY

				// configure output manifests to stacks/foo/components/bar/bar.gen.yaml
				// for component bar.
				parameters: outputBaseDir: "stacks/\(metadata.name)"
			}
		}
	}
}
