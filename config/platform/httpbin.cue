package platform

import "holos.example/types/platform"

projects: httpbin: (platform.#ProjectBuilder & {
	let IMAGE = "ghcr.io/mccutchen/go-httpbin"
	let PROJECT_NAME = parameters.name
	let STAGES = stages

	parameters: {
		name: "httpbin"

		// components to manage in each stage
		components: httpbin: {
			name: "httpbin"
			path: "stacks/httpbin/components/httpbin"
			parameters: image: IMAGE
		}

		// Stages organized by prod and nonprod so we can easily get a handle on all
		// prod stages, for example in the HTTPRoute below.
		stages: STAGES & {
			let NONPROD = {tier: "nonprod"}
			dev: NONPROD & {prior: "direct"}
			test: NONPROD & {prior: "dev"}
			uat: NONPROD & {prior: "test"}
			let PROD = {
				tier:  "prod"
				prior: "uat"
				// We have to stringify all injected tags.  This is a reason to switch to
				// passing the component over standard input as structured data.
				component: parameters: replicaCount: "2"
				component: parameters: version:      "v2.14.0"
			}
			"prod-us-east":    PROD
			"prod-us-central": PROD
			"prod-us-west":    PROD
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
			parameters: semverConstraint: "^2.0.0"
		}
	}
}).project
