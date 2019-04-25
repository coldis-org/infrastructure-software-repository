import org.sonatype.nexus.blobstore.api.BlobStoreManager

// Configures docker repositories.
repository.createDockerHosted('docker', null, 18444)
repository.createDockerProxy('docker-hub',                   // name
		'https://registry-1.docker.io', // remoteUrl
		'HUB',                          // indexType
		null,                           // indexUrl
		null,                           // httpPort
		null,                           // httpsPort
		BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName
		true, // strictContentTypeValidation
		true  // v1Enabled
		)
repository.createDockerGroup('docker-all', null, 18443, ['docker', 'docker-hub'], true)

// Configures NPM repositories.
repository.createNpmHosted('npm');
repository.createNpmProxy('npmjs-org', 'https://registry.npmjs.org');
repository.createNpmGroup('npm-all', ['npmjs-org', 'npm-internal'])

