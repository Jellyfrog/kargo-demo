package platform

import "holos.example/types/platform"

projects: podinfo: (platform.#ProjectBuilder & {
	let IMAGE = "stefanprodan/podinfo"
	let PROJECT_NAME = parameters.name
	let STAGES = stages

	parameters: {
		name: "podinfo"
		// Stages organized by prod and nonprod so we can easily get a handle on all
		// prod stages, for example in the HTTPRoute below.
		stages: STAGES & {
			let PARAMS = {
				metadata: name: string
				component: parameters: message: "Hello! Stage: \(metadata.name)"
			}
			let NONPROD = PARAMS & {
				tier: "nonprod"
				component: parameters: version: "6.7.0"
			}
			dev: NONPROD & {prior: "direct"}
			test: NONPROD & {prior: "dev"}
			uat: NONPROD & {prior: "test"}
			let PROD = PARAMS & {
				tier:  "prod"
				prior: "uat"
				// We have to stringify all injected tags.  This is a reason to switch to
				// passing the component over standard input as structured data.
				component: parameters: replicaCount: "2"
			}
			"prod-us-east": PROD & {
				component: parameters: version: "6.6.1"
			}
			"prod-us-central": PROD & {
				component: parameters: version: "6.6.2"
			}
			"prod-us-west": PROD & {
				component: parameters: version: "6.7.0"
			}
		}
		components: "podinfo": {
			name: "podinfo"
			path: "stacks/podinfo/components/podinfo"
			parameters: image: IMAGE
		}
	}
	project: stack: components: {
		// Compose the Kargo promotion stages into the holos project components.
		// Project owners are expected to copy the component path into
		// projects/<project name>/components/kargo-stages and customize it as needed
		// to define their promotion process.
		"project:\(PROJECT_NAME):component:kargo-stages": {
			name: "kargo-stages"
			path: "stacks/shared/components/kargo-stages"
			parameters: image:            IMAGE
			parameters: project:          PROJECT_NAME
			parameters: semverConstraint: "^6.0.0"
		}
	}
}).project
