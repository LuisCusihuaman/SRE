package test

import (
	"fmt"
	httpHelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"strings"
	"testing"
	"time"
)

func TestHelloWorldAppExample(t *testing.T) {
	opts := &terraform.Options{
		// You should update this relative path to point at your
		// hello-world-app example directory!
		TerraformDir: "../examples/hello-world-app/standalone",
		Vars: map[string]interface{}{
			"mysql_config": map[string]interface{}{
				"address": "mock-value-for-test",
				"port":    3306,
			},
		},
	}

	// Clean up everything at the end of the test
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	expectedStatus := 200
	expectedBody := "Hello, World"

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	httpHelper.HttpGetWithRetryWithCustomValidation(
		t, url, nil,
		maxRetries, timeBetweenRetries,
		func(status int, body string) bool {
			return status == expectedStatus && strings.Contains(body, expectedBody)
		},
	)
}
