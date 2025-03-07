package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"os"

	oai "github.com/Azure/azure-sdk-for-go/sdk/ai/azopenai"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/to"
)

type VCAPServices struct {
	AIService []struct {
		Credentials Credentials `json:"credentials"`
	} `json:"tts-azure-ai-model"`
}

// Credentials for accessing the Azure OpenAI service.
type Credentials struct {
	APIKey         string `json:"api_key"`
	Endpoint       string `json:"endpoint_url"`
	ModelName      string `json:"model_name"`
	ModelVersion   string `json:"model_version"`
	DeploymentName string `json:"deployment_name"`
}

// credentials extracts the information required to authenticate to the Azure Cognitive Services deployment from VCAP_SERVICES.
func credentials() (Credentials, error) {
	slog.Info("Loading credentials from VCAP_SERVICES")
	vcapServices := os.Getenv("VCAP_SERVICES")
	var services VCAPServices
	err := json.Unmarshal([]byte(vcapServices), &services)
	if err != nil {
		return Credentials{}, fmt.Errorf("unmarshalling VCAP_SERVICES: %w", err)
	}

	creds := services.AIService[0].Credentials

	// An older version of the brokerpak included an unnecessary path at the end of the endpoint URL. The Azure SDK adds the path automatically, so including it here caused an error. This code removes the path.
	u, err := url.Parse(creds.Endpoint)
	if err != nil {
		return Credentials{}, err
	}
	u.Path = ""
	creds.Endpoint = u.String()

	return creds, nil
}

func newOpenAIClient(apiKey string, endpoint string) (*oai.Client, error) {
	keyCredential := azcore.NewKeyCredential(apiKey)
	client, err := oai.NewClientWithKeyCredential(endpoint, keyCredential, nil)

	if err != nil {
		return nil, fmt.Errorf("creating OpenAI client: %w", err)
	}
	return client, nil
}

// main starts a web server that listens for requests on all paths. If users provide a query parameter prompt=, the server requests a chat completion from the Azure OpenAI model with the prompt as the first message, and returns the results to the user.
func main() {
	creds, err := credentials()
	if err != nil {
		slog.Error("loading Azure OpenAI credentials from VCAP_SERVICES", "err", err)
	}
	client, err := newOpenAIClient(creds.APIKey, creds.Endpoint)
	if err != nil {
		slog.Error("authenticating to Azure OpenAI", "err", err)
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if client == nil {
			http.Error(w, "Internal error creating Azure client", http.StatusInternalServerError)
		}
		prompt := r.FormValue("prompt")
		if prompt == "" {
			http.Error(w, "Error: Query parameter 'prompt' missing or empty.", http.StatusBadRequest)
			return
		}
		slog.Info("Making request to Azure...", "prompt", prompt)
		resp, err := client.GetChatCompletions(r.Context(), oai.ChatCompletionsOptions{
			Messages: []oai.ChatRequestMessageClassification{
				&oai.ChatRequestUserMessage{
					Content: oai.NewChatRequestUserMessageContent(prompt),
				},
			},
			MaxTokens:      to.Ptr(int32(512)),
			Temperature:    to.Ptr(float32(0.0)),
			DeploymentName: &creds.DeploymentName,
		}, nil)

		if err != nil {
			http.Error(w, fmt.Errorf("Error querying Azure OpenAI completions API: %w", err).Error(), http.StatusInternalServerError)
			return
		}
		slog.Info("Got response from Azure: ", "content", *resp.Choices[0].Message.Content)
		io.WriteString(w, *resp.Choices[0].Message.Content)
	})

	slog.Info("Starting server...")
	http.ListenAndServe(":8080", nil)
}
