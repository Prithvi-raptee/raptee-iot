package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
)

// Configuration
const (
	Region   = "ap-south-1"
	Account  = "730335440068"
	RepoName = "raptee-go-api"
)

func main() {
	ecrURL := fmt.Sprintf("%s.dkr.ecr.%s.amazonaws.com", Account, Region)
	imageURI := fmt.Sprintf("%s/%s:latest", ecrURL, RepoName)

	fmt.Println("Starting Raptee Deployment Sequence...")

	// STEP 1: AWS ECR Login
	// We run 'aws ecr get-login-password' and pipe it securely to 'docker login'
	fmt.Println("\n1. Authenticating with AWS ECR...")
	tokenCmd := exec.Command("aws", "ecr", "get-login-password", "--region", Region)
	tokenOutput, err := tokenCmd.Output()
	if err != nil {
		fail("Failed to get AWS token. Are you logged in via 'aws configure'?", err)
	}

	loginCmd := exec.Command("docker", "login", "--username", "AWS", "--password-stdin", ecrURL)
	loginCmd.Stdin = bytes.NewBuffer(tokenOutput) // Securely pipe password
	loginCmd.Stdout = os.Stdout
	loginCmd.Stderr = os.Stderr
	if err := loginCmd.Run(); err != nil {
		fail("Docker login failed", err)
	}

	// STEP 2: Docker Build
	fmt.Println("\n2. Building Docker Image...")
	// Note: We use -f Dockerfile and context .
	buildCmd := exec.Command("docker", "build", "-t", imageURI, "-f", "Dockerfile", ".")
	buildCmd.Stdout = os.Stdout
	buildCmd.Stderr = os.Stderr
	if err := buildCmd.Run(); err != nil {
		fail("Docker build failed", err)
	}

	// STEP 3: Docker Push
	fmt.Println("\n3. Pushing to AWS ECR...")
	pushCmd := exec.Command("docker", "push", imageURI)
	pushCmd.Stdout = os.Stdout
	pushCmd.Stderr = os.Stderr
	if err := pushCmd.Run(); err != nil {
		fail("Docker push failed", err)
	}

	fmt.Println("\nDeployment to ECR Successful!")
	fmt.Println("   Next: Go to AWS App Runner console and click 'Deploy' if not set to Auto.")
}

func fail(msg string, err error) {
	fmt.Printf("ERROR: %s\nDetails: %v\n", msg, err)
	os.Exit(1)
}