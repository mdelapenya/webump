package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var allowGitTag bool
var dryRun bool
var versionFileName string

func init() {
	rootCmd.Flags().BoolVarP(
		&dryRun, "dry-run", "d", false,
		"Enables dry-run mode, which only prints out the result of the bump. (default false)")
	rootCmd.Flags().BoolVarP(
		&allowGitTag, "allow-git-tag", "g", true,
		"Enables allow-git-tag mode, which creates a git tag with the bump.")
	rootCmd.Flags().StringVarP(
		&versionFileName, "version-file", "v", "VERSION.txt",
		"Sets the file where to read the version to bump.")
}

var rootCmd = &cobra.Command{
	Use:   "webump",
	Short: "webump (We Bump) makes it easier to bump WeDeploy's projects.",
	Long: `A Fast, Flexible, and Oppinionated CLI for managing WeDeploy's projects
				built with love by WeDeploy and friends in Go.`,
	Run: func(cmd *cobra.Command, args []string) {
		// Do Stuff Here
	},
}

// Execute execute root command
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
