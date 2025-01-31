// main.go
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/tailscale/tailscale-client-go/tailscale"
)

type Config struct {
	ClientID     string
	ClientSecret string
	Operation    string
	DeviceID     string
	Tags         []string
	ACLPolicy    string
}

func getEnvOrExit(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("Environment variable %s is required", key)
	}
	return value
}

func main() {
	config := parseFlags()

	ctx := context.Background()
	if err := executeOperation(ctx, config); err != nil {
		log.Fatalf("Operation failed: %v", err)
	}
}

func parseFlags() *Config {
	config := &Config{}

	// Command line flags
	flag.StringVar(&config.Operation, "operation", "", "Operation to perform (get-devices, get-acl, update-acl, update-device-tags)")
	flag.StringVar(&config.DeviceID, "device-id", "", "Device ID for tag operations")
	tagsStr := flag.String("tags", "[]", "Tags as JSON array")
	flag.StringVar(&config.ACLPolicy, "acl-policy", "", "ACL policy as JSON string")
	flag.Parse()

	// Environment variables
	config.ClientID = getEnvOrExit("TS_CLIENT_ID")
	config.ClientSecret = getEnvOrExit("TS_CLIENT_SECRET")

	// Parse tags if provided
	if err := json.Unmarshal([]byte(*tagsStr), &config.Tags); err != nil {
		log.Fatalf("Failed to parse tags: %v", err)
	}

	if config.Operation == "" {
		log.Fatal("Operation is required")
	}

	return config
}


func createClient(clientID, clientSecret string) (*tailscale.Client, error) {
    client, err := tailscale.NewClient(
        tailscale.WithCredentials(clientID, clientSecret),
    )
    if err != nil {
        return nil, fmt.Errorf("failed to create client: %w", err)
    }

    return client, nil
}

func executeOperation(ctx context.Context, config *Config) error {
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	switch config.Operation {
	case "get-devices":
		return handleGetDevices(ctx, config)
	case "get-acl":
		return handleGetACL(ctx, config)
	case "update-acl":
		return handleUpdateACL(ctx, config)
	case "update-device-tags":
		return handleUpdateDeviceTags(ctx, config)
	default:
		return fmt.Errorf("unknown operation: %s", config.Operation)
	}
}

func handleGetDevices(ctx context.Context, config *Config) error {
	client, err := createClient(config.ClientID, config.ClientSecret)
	if err != nil {
		return err
	}

	devices, err := client.Devices(ctx)
	if err != nil {
		return fmt.Errorf("failed to get devices: %w", err)
	}

	return outputJSON(devices)
}

func handleGetACL(ctx context.Context, config *Config) error {
	client, err := createClient(config.ClientID, config.ClientSecret)
	if err != nil {
		return err
	}

	acl, err := client.ACL(ctx)
	if err != nil {
		return fmt.Errorf("failed to get ACL: %w", err)
	}

	return outputJSON(acl)
}

func handleUpdateACL(ctx context.Context, config *Config) error {
	client, err := createClient(config.ClientID, config.ClientSecret)
	if err != nil {
		return err
	}

	var policy tailscale.ACL
	if err := json.Unmarshal([]byte(config.ACLPolicy), &policy); err != nil {
		return fmt.Errorf("failed to parse ACL policy: %w", err)
	}

	if err := client.SetACL(ctx, &policy); err != nil {
		return fmt.Errorf("failed to update ACL: %w", err)
	}

	fmt.Println("ACL updated successfully")
	return nil
}

func handleUpdateDeviceTags(ctx context.Context, config *Config) error {
	if config.DeviceID == "" {
		return fmt.Errorf("device ID is required for tag operations")
	}

	client, err := createClient(config.ClientID, config.ClientSecret)
	if err != nil {
		return err
	}

	if err := client.SetDeviceTags(ctx, config.DeviceID, config.Tags); err != nil {
		return fmt.Errorf("failed to update device tags: %w", err)
	}

	fmt.Println("Tags updated successfully")
	return nil
}

func outputJSON(data interface{}) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	return encoder.Encode(data)
}