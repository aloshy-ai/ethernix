// main_test.go
package main

import (
	"context"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParseFlags(t *testing.T) {
	// Save original args and env
	oldArgs := os.Args
	oldEnv := map[string]string{
		"TS_CLIENT_ID":     os.Getenv("TS_CLIENT_ID"),
		"TS_CLIENT_SECRET": os.Getenv("TS_CLIENT_SECRET"),
	}
	
	// Restore after test
	defer func() {
		os.Args = oldArgs
		for k, v := range oldEnv {
			os.Setenv(k, v)
		}
	}()

	// Set up test environment
	os.Setenv("TS_CLIENT_ID", "test-client-id")
	os.Setenv("TS_CLIENT_SECRET", "test-client-secret")

	tests := []struct {
		name    string
		args    []string
		wantErr bool
		want    *Config
	}{
		{
			name: "valid get-devices",
			args: []string{"-operation", "get-devices"},
			want: &Config{
				ClientID:     "test-client-id",
				ClientSecret: "test-client-secret",
				Operation:    "get-devices",
				Tags:        []string{},
			},
		},
		{
			name: "valid update-device-tags",
			args: []string{
				"-operation", "update-device-tags",
				"-device-id", "test-device",
				"-tags", `["tag:ci"]`,
			},
			want: &Config{
				ClientID:     "test-client-id",
				ClientSecret: "test-client-secret",
				Operation:    "update-device-tags",
				DeviceID:    "test-device",
				Tags:        []string{"tag:ci"},
			},
		},
		{
			name:    "missing operation",
			args:    []string{},
			wantErr: true,
		},
		{
			name:    "invalid tags json",
			args:    []string{"-operation", "update-device-tags", "-tags", "invalid-json"},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			os.Args = append([]string{"cmd"}, tt.args...)

			if tt.wantErr {
				assert.Panics(t, func() { parseFlags() })
			} else {
				config := parseFlags()
				assert.Equal(t, tt.want, config)
			}
		})
	}
}

func TestExecuteOperation(t *testing.T) {
	tests := []struct {
		name    string
		config  *Config
		wantErr bool
	}{
		{
			name: "invalid operation",
			config: &Config{
				Operation: "invalid-operation",
			},
			wantErr: true,
		},
		{
			name: "missing device id",
			config: &Config{
				Operation: "update-device-tags",
				Tags:     []string{"tag:ci"},
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := executeOperation(context.Background(), tt.config)
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}