//
// Copyright (c) 2025 Sumicare
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//

// Package templating provides utilities for rendering templates with version data.
// It includes functionality for processing template files and substituting version
// information for package management and documentation generation.
package templating

import (
	"bytes"
	"fmt"
	"os"
	"text/template"

	"sumi.care/util/sumicare-versioning/pkg"
	"sumi.care/util/sumicare-versioning/pkg/templating/chunks"
)

const (
	// defaultDirectoryPermission755 = 0o755.

	// defaultFilePermission600 applied to all written files.
	defaultFilePermission600 = 0o600
)

// TemplateData represents the data structure for template rendering.
type TemplateData struct {
	Versions   map[string]string
	Org        string
	Repository string
}

// RenderTemplate renders a template file with the provided data and returns the result.
func RenderTemplate(templatePath string, data TemplateData) (string, error) {
	// Read the template file
	templateContent, err := os.ReadFile(templatePath)
	if err != nil {
		return "", fmt.Errorf("failed to read template file %s: %w", templatePath, err)
	}

	repos := pkg.Repos()

	// Parse the template
	tmpl, err := template.New("terraform").Funcs(template.FuncMap{
		"GeneratedCommentStub": chunks.GeneratedCommentStub,
		"ImageProviders":       chunks.ImageProviders,
		"ChartProviders":       chunks.ChartProviders,
		"OrgRepoStub":          chunks.OrgRepoStub,
		"EnvStub":              chunks.EnvStub,
		"DebianVersionVariable": func() string {
			return chunks.DebianVersionVariable(data.Versions["debian"])
		},
		"RegistryAuthVariable": chunks.RegistryAuthVariable,
		"ImageVariablesStub": func() string {
			return chunks.ImageVariablesStub(data.Versions["debian"])
		},
		"ChartVariablesStub":      chunks.ChartVariablesStub,
		"DockerImageResources":    chunks.DockerImageResources,
		"DockerImageDigestOutput": chunks.DockerImageDigestOutput,
		"DockerfileHeader": func() string {
			return chunks.DockerfileHeader(data.Versions["debian"])
		},
		"DockerfileBuildHeader": func(name, alias string) string {
			return chunks.DockerfileBuildHeader(name, data.Versions["debian"], data.Versions[alias], repos[alias])
		},
		"GoBinaryDockerfile": func(name, alias, ldflags, versionPrefix, workdir, pkg string) string {
			return chunks.GoBinaryDockerfile(name, data.Versions["debian"], data.Versions[alias], repos[alias], ldflags, versionPrefix, workdir, pkg)
		},
		"GoBinariesDockerfile": func(name, alias, versionPrefix, workdir string, namePkgLDFlags ...string) string {
			return chunks.GoBinariesDockerfile(name, data.Versions["debian"], data.Versions[alias], repos[alias], versionPrefix, workdir, namePkgLDFlags...)
		},
		"BuildGoBinariesDockerfile": chunks.BuildGoBinariesDockerfile,
		"DistrolessUnpack":          chunks.DistrolessUnpack,
	}).Parse(string(templateContent))
	if err != nil {
		return "", fmt.Errorf("failed to parse template: %w", err)
	}

	// Execute the template
	var buf bytes.Buffer

	err = tmpl.Execute(&buf, data)
	if err != nil {
		return "", fmt.Errorf("failed to execute template: %w", err)
	}

	return buf.String(), nil
}

// RenderTemplateToFile renders a template and writes the result to a file.
func RenderTemplateToFile(templatePath, outputPath string, data TemplateData) error {
	content, err := RenderTemplate(templatePath, data)
	if err != nil {
		return fmt.Errorf("failed to render template %s: %w", templatePath, err)
	}

	// Write the rendered content to the output file
	err = os.WriteFile(outputPath, []byte(content), defaultFilePermission600)
	if err != nil {
		return fmt.Errorf("failed to write output file %s: %w", outputPath, err)
	}

	return nil
}
