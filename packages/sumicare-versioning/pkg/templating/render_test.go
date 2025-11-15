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

package templating

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Templating", func() {
	type renderTestCase struct {
		templateContent string
		data            TemplateData
		expectedOutput  string
		shouldError     bool
	}

	DescribeTable("RenderTemplate",
		func(tc renderTestCase) {
			tempDir, err := os.MkdirTemp("", "templating-test")
			Expect(err).NotTo(HaveOccurred(), "should be able to create temp directory")
			defer os.RemoveAll(tempDir)

			templateFile := filepath.Join(tempDir, "test.tpl")
			err = os.WriteFile(templateFile, []byte(tc.templateContent), defaultFilePermission600)
			Expect(err).NotTo(HaveOccurred(), "should be able to write template file")

			result, err := RenderTemplate(templateFile, tc.data)

			if tc.shouldError {
				Expect(err).To(HaveOccurred(), "should return error when expected")
			} else {
				Expect(err).NotTo(HaveOccurred(), "should not return error when not expected")
				Expect(result).To(Equal(tc.expectedOutput), "rendered result should match expected output")
			}
		},
		Entry("render template with version data",
			renderTestCase{
				templateContent: `Version: {{index .Versions "compute-descheduler"}}`,
				data: TemplateData{
					Versions: map[string]string{
						"compute-descheduler": "1.2.3",
					},
				},
				expectedOutput: "Version: 1.2.3",
				shouldError:    false,
			},
		),
		Entry("render template with multiple versions",
			renderTestCase{
				templateContent: `Descheduler: {{index .Versions "compute-descheduler"}}, Debian: {{index .Versions "debian"}}`,
				data: TemplateData{
					Versions: map[string]string{
						"compute-descheduler": "1.2.3",
						"debian":              "bookworm",
					},
				},
				expectedOutput: "Descheduler: 1.2.3, Debian: bookworm",
				shouldError:    false,
			},
		),
		Entry("render template with org and repository",
			renderTestCase{
				templateContent: `Org: {{.Org}}, Repo: {{.Repository}}`,
				data: TemplateData{
					Org:        "sumicare",
					Repository: "docker.io/",
				},
				expectedOutput: "Org: sumicare, Repo: docker.io/",
				shouldError:    false,
			},
		),
		Entry("render template with function calls",
			renderTestCase{
				templateContent: `{{ GeneratedCommentStub }}`,
				data:            TemplateData{},
				expectedOutput:  "###           DO NOT EDIT            ###\n# This file is automagically generated #",
				shouldError:     false,
			},
		),
		Entry("error on invalid template syntax",
			renderTestCase{
				templateContent: `Hello {{ .MissingField }`,
				data:            TemplateData{},
				expectedOutput:  "",
				shouldError:     true,
			},
		),
	)

	It("should error if template file does not exist", func() {
		data := TemplateData{}
		_, err := RenderTemplate("non-existent.tpl", data)
		Expect(err).To(HaveOccurred(), "should return error for non-existent template file")
	})

	DescribeTable("RenderTemplateToFile",
		func(tc renderTestCase) {
			tempDir, err := os.MkdirTemp("", "templating-test")
			Expect(err).NotTo(HaveOccurred(), "should be able to create temp directory")
			defer os.RemoveAll(tempDir)

			templateFile := filepath.Join(tempDir, "test.tpl")
			outputFile := filepath.Join(tempDir, "test.gen")

			err = os.WriteFile(templateFile, []byte(tc.templateContent), defaultFilePermission600)
			Expect(err).NotTo(HaveOccurred(), "should be able to write template file")

			err = RenderTemplateToFile(templateFile, outputFile, tc.data)

			if tc.shouldError {
				Expect(err).To(HaveOccurred(), "should return error when expected")
			} else {
				Expect(err).NotTo(HaveOccurred(), "should not return error when not expected")

				content, err := os.ReadFile(outputFile)
				Expect(err).NotTo(HaveOccurred(), "should be able to read output file")
				Expect(string(content)).To(Equal(tc.expectedOutput), "output content should match expected")
			}
		},
		Entry("render template to file with version data",
			renderTestCase{
				templateContent: `Version: {{index .Versions "compute-descheduler"}}`,
				data: TemplateData{
					Versions: map[string]string{
						"compute-descheduler": "1.0.0",
					},
				},
				expectedOutput: "Version: 1.0.0",
				shouldError:    false,
			},
		),
		Entry("render complex template to file",
			renderTestCase{
				templateContent: `# {{.Org}}/{{.Repository}}
Version: {{index .Versions "compute-keda"}}`,
				data: TemplateData{
					Org:        "sumicare",
					Repository: "ghcr.io/",
					Versions: map[string]string{
						"compute-keda": "2.18.1",
					},
				},
				expectedOutput: "# sumicare/ghcr.io/\nVersion: 2.18.1",
				shouldError:    false,
			},
		),
	)
})
