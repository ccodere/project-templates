Software Build Procedure
========================

Scope
-----

This document defines the procedure for building, packaging, and releasing the
software from source. It covers the environment prerequisites, environment setup,
and the sequential steps required to produce development, debug, and release
artifacts using the Maven build system.

This document does not cover release governance, version numbering policy, tagging
conventions, or release authorization. Those topics are addressed in the
Configuration Management Plan if any is available. 

This document does not cover software architecture, component design, 
or interface specifications. 

Applicable Documents
--------------------

The following documents are referenced by or related to this procedure:

**Apache Maven documentation** â€” `https://maven.apache.org/guides/`

**Azul Zulu JDK downloads** â€” `https://www.azul.com/downloads/`

Build Environment Requirements
-------------------------------

The following prerequisites must be satisfied on the build machine before executing
any procedure in this document.

### Software prerequisites

- Maven version 3.9.0 or later.
- Java runtime environment 8 or later.
- Git
- GPG 2.x or later  
- Java Development Kit requirements depend on the build profile:
  - **dev and debug profiles (default):** Any JDK from 8 up to and including JDK 17
    is sufficient.
  - **release profile:** Requires a JDK 1.6 installation declared as a Maven toolchain
    in `settings.xml` (see Environment Setup below). The recommended source is Azul
    Zulu 6, freely available at `https://www.azul.com/downloads/`. The toolchain ensures
    genuine JDK 1.6 bytecode output regardless of the JDK used to invoke Maven.

Java compilation follows the Maven 4.0.0 model.

### Hardware prerequisites

- At least 64 MiB of free hard disk space.

Environment Setup
-----------------

The steps in this section are executed once per build machine or environment. They
are prerequisites for the build and release procedures that follow.


### Setup PATH

Add the `bin` directory of the apache-maven installation directory
to the `PATH` environment variable.

Add the directory of the GPG executable installation directory
to the `PATH` environment variable.

Add the directory of the Git executable installation directory
to the `PATH` environment variable.

### Verify all tools are correctly setup

Verify each is on your `PATH`:

```bash
java -version
mvn -version
git --version
gpg --version
```



### Repository credentials

If artifacts are to be deployed to a remote repository, the Maven `settings.xml`
file located in the `~/.m2/settings.xml` directory must contain valid deployment credentials. The
following example configures credentials for the `sonatype` and `github.com` servers 
as well as the `gpg` artifact signing.

```xml
<servers>

    <!-- Sonatype Central credentials (user token, NOT your portal password) -->
    <server>
      <id>central</id>
      <username>YOUR_CENTRAL_TOKEN_USERNAME</username>
      <password>YOUR_CENTRAL_TOKEN_PASSWORD</password>
    </server>
    <!-- GPG passphrase. The id MUST match the gpg.keyname property
         in the parent pom (627E3C7E) because the gpg plugin is configured
         with <passphraseServerId>${gpg.keyname}</passphraseServerId>. -->
    <server>
      <id>627E3C7E</id>
      <passphrase>YOUR_GPG_PASSPHRASE</passphrase>
    </server>
  <server>
    <!-- Github connection information -->
    <id>github.com</id>
    <username>TheUserName</username>
    <password>YOUR_CENTRAL_TOKEN_PASSWORD</password>
  </server>
</servers>
```

### Compilation toolchain configuration

To build the `release` profile, the `settings.xml` file must also declare the
appropriate JDK toolchain so that Maven can locate the correct compiler. 
Without this entry, the
`release` profile will fail with a toolchain resolution error. This entry is _not_
required for the `dev`, `debug` profiles.

Add the following `<properties>` block to `~/.m2/settings.xml`, adjusting the path
to match the actual JDK installation on the build machine:

```xml
   <profiles>
      <profile>
          <id>release</id>
            <properties>
              <JAVA1_4_HOME>/path/to/jdk1.6</JAVA1_4_HOME>
              <JAVA6_HOME>/path/to/jdk6</JAVA6_HOME>
            </properties>
      </profile>
    </profiles>
```

Build Configuration Reference
------------------------------

This section is informative. It describes the build profiles and configurable
properties that the procedures in this document operate upon.

### Generated MANIFEST.MF fields

All Java-related projects automatically generate a standard `MANIFEST.MF` file which
shall contain minimally the following information, if specified in the Maven project file:

* `Implementation-Vendor` with the value equal to the `${project.organization.name}` property
* `Implementation-Title` with the value equal to the `${project.name}` property.
* `Implementation-Version` with the value equal to the `${project.version}` property.

### Build profiles

**dev**

Generates the release executable artifacts for deployment to a local repository with
optimizations enabled and limited debugging information as well as API documentation
in packaging required for repository deployment. This is the _default_ active profile
when building.

**release**

Generates the release artifacts for deployment to the deployment repository with
optimization, signing and limited debugging information as well as generic source,
binary and documentation packages for local web site distribution.

**debug**

Generates the debug executable artifacts with the `debug` classifier for local
repository deployment with full debugging information.

### Configurable properties

The following properties may be overridden on the Maven command line to modify
compilation behaviour:

**maven.compiler.source**

Sets the source version for compilation. Applies to all profiles.

**maven.compiler.target**

Sets the target version for compilation. Applies to all profiles.

**gpg.keyname**

Sets the key ID used for signing the artifacts. Applies to the `release` profile.

Build Targets Reference
------------------------

This section is informative. It describes the effect of each Maven build target
available in this project.

**clean**

Cleans all files generated by compiling and preparation of the distribution files.
Among others it cleans generated resources, documentation, compilation artifacts
and data packages. It does not delete build configuration data used for building.

**compile**

Compiles and links if necessary the software and generates all related data used
directly by the software (such as resources).

**deploy**

Copies the final data packages or distribution archives to the remote repository
for sharing with others.

**install**

In the case of a library, installs the package into the local repository, for use
as a dependency in other projects locally. Package installation installs everything
for the distribution, including documentation, resources and compiled binaries that
may have been generated in the package phase.

**package**

Creates a distribution archive for this software containing the binaries, resources
and documentation. The root of the archive is the actual directory name of the
software project name, with a potential version name, for example `myproject-1.0.0`.
The `package` target explicitly depends on all non-source files that are in the
distribution, to make sure they are up to date in the distribution, including
generated documentation and resources. This target may also generate data packages
in required formats used for deployment in the `deploy` target.

**test**

Tests the compiled source code through a unit testing framework. Testing does not
require the software to be deployed or installed beforehand.

**uninstall**

In the case of a library, deletes the previously installed files from the local
repository, including configuration data. This target does not modify the directories
where compilation is done, only the directories where files are installed.

Build and deployment procedures
-------------------------------
### Build procedure

The following steps shall be executed to produce a standard development build.
Complete the Environment Setup steps before proceeding.

1. Execute `mvn install` to build and install the `dev` profile package for day to
   day development.
2. Execute `mvn -P debug install` to build and install the `debug` profile packages.
3. Execute `mvn site` to build and create the documentation associated with the project.
4. Execute `mvn -P release package` to generate and sign the standard release
   artifacts, as well as creating independently package installable release artifacts.

### Deployment procedure

The following steps shall be executed to prepare and deploy a release. Complete the
Build Procedure above before proceeding.

1. Update `/src/changes/changes.xml` by doing the following:
   1. Add a new release element with version and description attributes.
   2. Add action elements under the newly created release element with at least the
      type attribute (`add`, `update`, `remove`, `fix`) and content describing the
      changes in a high-level fashion.
2. Execute `mvn clean`.
3. Execute `mvn package` to build the `dev` profile package.
4. Execute `mvn install` to install the `dev` profile package into the local repository.
4. Execute `mvn -P debug install` to build and install the `debug` profile packages.
5. Execute `mvn site` to build and create the documentation associated with the project.
6. Execute `mvn -P release package` to generate and sign the standard release
   artifacts, as well as creating independently package installable release artifacts.
7. Execute `mvn release:prepare -DdryRun=true` to verify the release preparation
   without committing any changes.
8. Execute `mvn release:perform -DdryRun=true` to verify the release deployment
   without publishing any artifacts.
9. Execute `mvn release:prepare` to perform the actual release preparation and tagging.
10. Execute `mvn release:perform` to deploy the release artifacts to the remote repository.

#### After the upload

The Sonatype Central deployment may need a manual release click in the portal,
depending on plugin defaults. Check the deployment status at
<https://central.sonatype.com/publishing/deployments> and release it manually if
it's in a `VALIDATED` state awaiting confirmation.

### Troubleshooting

#### Recovering from a failed `release:prepare`

* Failed before commit/tag was created : `mvn release:rollback`
* Tag was created locally but not pushed : `git tag -d v1.1.0`, then `mvn release:rollback`
* Tag was already pushed when failure occurred : `git push --delete origin v1.1.0`, then `mvn release:rollback`
* Leftover `release.properties` / backup POMs : `mvn release:clean` |

#### Others errors

**`gpg: signing failed: No such file or directory`** — `gpg-agent` is not running
or cannot prompt for the passphrase. Ensure the passphrase is in `settings.xml` (under
the server id) or configure `gpg-agent` and `pinentry`.

**`401 Unauthorized` from Sonatype Central** — the user token in `settings.xml` is
incorrect, expired, or you used your portal password instead of a generated user token.
Regenerate the token at <https://central.sonatype.com>.

Coding conventions
------------------
The following coding conventions are used in development of Java code:

- Braces placement follows the Allman style/BSD style as used by Eric Allman, in other words
  this style puts the brace associated with a control statement on the next line, 
  indented to the same level as the control statement. Statements within the braces are 
  indented to the next level.
- Indentation size is 2 spaces for each code block.  
