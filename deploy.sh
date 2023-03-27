#!/bin/bash

set -e -o pipefail
export VERSION=${VERSION:-5.3.5-ls01}
export ARTIFACT_ID=${ARTIFACT_ID:-spring-data-elasticsearch}
export GROUP_ID=${GROUP_ID:-org.springframework.data}

# build and install in local maven repo
if [ -f ./mvnw ]; then
  ./mvnw clean javadoc:jar install -DskipTests=true -Dversion="${VERSION}"
elif [ -f ./gradlew ]; then
  ./gradlew clean build -x test publishToMavenLocal
fi

export BASE_DIR=~/.m2/repository/${GROUP_ID//./\/}/${ARTIFACT_ID}/${VERSION}
COPIED=$(mktemp -d) # mvn deploy doesn't like installing from local repo
cp -r "${BASE_DIR}"/* "$COPIED"
mvnd org.apache.maven.plugins:maven-deploy-plugin:3.0.0:deploy-file \
  -Durl=https://maven.pkg.github.com/lightspeed-payments/lsp-maven-repository \
  -DrepositoryId=lsp-repo \
  -Dfile="${COPIED}/${ARTIFACT_ID}-${VERSION}.jar" \
  -DpomFile="${COPIED}/${ARTIFACT_ID}-${VERSION}.pom" \
  -Dsources="${COPIED}/${ARTIFACT_ID}-${VERSION}-sources.jar" \
  -Djavadoc="${COPIED}/${ARTIFACT_ID}-${VERSION}-javadoc.jar"
