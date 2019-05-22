import org.sonatype.nexus.blobstore.api.BlobStoreManager

// Configures docker repositories.
repository.createDockerHosted('docker', 18444, null)
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
repository.createDockerGroup('docker-all', 18443, null, ['docker', 'docker-hub'], false)

// Configures NPM repositories.
repository.createNpmHosted('npm');
repository.createNpmProxy('npmjs-org', 'https://registry.npmjs.org');
repository.createNpmGroup('npm-all', ['npm', 'npmjs-org'])

