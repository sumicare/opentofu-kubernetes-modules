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

package crds

import (
	"bufio"
	"fmt"
	"strings"
)

const (
	// unknownCRDName is the default name for unknown CRDs.
	unknownCRDName = "unknown-crd"
)

// ExtractCRDsFromContent splits multi-document YAML into individual CRD documents.
func ExtractCRDsFromContent(content string) (map[string]string, error) {
	//nolint:wrapcheck // we're fine with propagation
	return splitMultiDocYAML(content)
}

// splitMultiDocYAML splits multi-document YAML into individual CRD documents.
func splitMultiDocYAML(content string) (map[string]string, error) {
	crds := make(map[string]string)
	scanner := bufio.NewScanner(strings.NewReader(content))
	buf := make([]byte, 0, defaultBufferSize)
	scanner.Buffer(buf, defaultBufferSize)

	var docBuilder strings.Builder

	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "---" {
			// Process the completed document
			if doc := strings.TrimSpace(docBuilder.String()); doc != "" {
				// Only include CustomResourceDefinition resources
				if isCRD, name := extractCRDInfo(doc); isCRD {
					crds[name+".yaml"] = doc
				}
			}

			docBuilder.Reset()
		} else {
			docBuilder.WriteString(line)
			docBuilder.WriteString("\n")
		}
	}

	// Handle last document
	if doc := strings.TrimSpace(docBuilder.String()); doc != "" {
		if isCRD, name := extractCRDInfo(doc); isCRD {
			crds[name+".yaml"] = doc
		}
	}

	err := scanner.Err()
	if err != nil {
		return nil, fmt.Errorf("failed to split multi-document YAML: %w", err)
	}

	return crds, nil
}

// extractCRDInfo checks if a YAML document is a CustomResourceDefinition and extracts its name.
// Returns a boolean indicating if it's a CRD and the name of the CRD.
func extractCRDInfo(content string) (bool, string) {
	// Check if this is a CRD
	isCRD := strings.Contains(content, "kind: CustomResourceDefinition")

	// Look for kind: CustomResourceDefinition

	// Also check apiVersion to ensure it's a CRD
	if strings.Contains(content, "apiextensions.k8s.io") && strings.Contains(content, "CustomResourceDefinition") {
		isCRD = true
	}

	if !isCRD {
		return false, ""
	}

	// Extract the name
	name := extractCRDName(content)

	return true, name
}

// extractCRDName extracts the CRD name from metadata.name field.
func extractCRDName(content string) string {
	// Look for metadata.name
	metadataIdx := strings.Index(content, "metadata:")
	if metadataIdx == -1 {
		return unknownCRDName
	}

	searchStart := metadataIdx + len("metadata:")

	nameIdx := strings.Index(content[searchStart:], "name:")
	if nameIdx == -1 {
		return unknownCRDName
	}

	nameIdx += searchStart

	lineStart := nameIdx + len("name:")

	lineEnd := strings.Index(content[lineStart:], "\n")
	if lineEnd == -1 {
		lineEnd = len(content) - lineStart
	}

	name := strings.TrimSpace(content[lineStart : lineStart+lineEnd])

	name = strings.Trim(name, "\"'")

	if name == "" {
		return unknownCRDName
	}

	return name
}

// generateTerraform generates crds.tf file content.
func generateTerraform(crds map[string]string) string {
	var sb strings.Builder
	sb.WriteString(autoGenLicenseHeader)

	for filename := range crds {
		resourceName := strings.TrimSuffix(filename, ".yaml")

		resourceName = strings.ReplaceAll(resourceName, ".", "_")
		resourceName = strings.ReplaceAll(resourceName, "-", "_")

		sb.WriteString(fmt.Sprintf(`resource "kubernetes_manifest" "customresourcedefinition_%s" {
  manifest = yamldecode(file("${path.module}/%s"))
}

`, resourceName, filename))
	}

	return sb.String()
}
