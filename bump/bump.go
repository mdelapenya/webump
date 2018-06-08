package bump

import (
	"log"
	"os"
)

const defaultWorkdir = "/version"
const gradleProperties = "gradle.properties"
const packageJSON = "package.json"

// bumpMode defines how a bump is performed
type mode int

const (
	//Custom custom mode
	Custom mode = iota
	//Gradle gradle mode
	Gradle
	//NodeJS nodejs mode
	NodeJS
)

func (m mode) String() string {
	modes := [...]string{
		"Custom",
		"Gradle",
		"NodeJS",
	}

	if m < Custom || m > NodeJS {
		return "Unknown"
	}

	return modes[m]
}

// Type defines the object that represents a bump type
type Type int

const (
	//Unknown not recognised bump types
	Unknown Type = iota
	//Build a build bump
	Build
	//Prerel a prerel bump
	Prerel
	//Patch a patch bump
	Patch
	//Minor a minor bump
	Minor
	//Major a major bump
	Major
)

func (t Type) String() string {
	types := [...]string{
		"Build",
		"Prerel",
		"Patch",
		"Minor",
		"Major",
	}

	if t < Build || t > Major {
		return "Unknown"
	}

	return types[t]
}

// bumper defines the object that represents a bump
type bumper struct {
	dryRun          bool
	gitEmail        string
	gitTag          bool
	gitUsername     string
	versionFileName string
	versionMode     string
	workdir         string
}

// Bump performs a bump in the version
func Bump(
	dryRun bool, gitEmail string, gitTag bool, gitUsername string, versionFileName string) error {

	var b = bumper{}

	b.dryRun = dryRun
	b.gitEmail = gitEmail
	b.gitTag = gitTag
	b.gitUsername = gitUsername
	b.versionFileName = versionFileName
	b.workdir = "/version"

	b, err := detectLanguage(b)

	if err == nil {
		log.Println(b.versionMode + " project detected.")
	}

	return err
}

func detectLanguage(b bumper) (bumper, error) {
	packageJSONFile := getFilePath(b.workdir, packageJSON)
	_, err := os.Stat(packageJSONFile)
	if err == nil {
		b.versionMode = NodeJS.String()
		b.versionFileName = packageJSON
		return b, nil
	}

	gradlePropertiesFile := getFilePath(b.workdir, gradleProperties)
	_, err = os.Stat(gradlePropertiesFile)
	if err == nil {
		b.versionMode = Gradle.String()
		b.versionFileName = gradleProperties
		return b, nil
	}

	customFile := getFilePath(b.workdir, b.versionFileName)
	_, err = os.Stat(customFile)
	if err == nil {
		b.versionMode = Custom.String()
		return b, nil
	}

	return b, err
}

func getFilePath(basePath string, fileName string) string {
	return basePath + string(os.PathSeparator) + fileName
}

func validate() {

}
