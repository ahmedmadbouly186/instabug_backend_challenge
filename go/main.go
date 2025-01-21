package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/go-redis/redis/v8"
)

var ctx = context.Background()

// Struct to represent the request body, if any
type ChatRequest struct {
	ChatNumber int `json:"chat_number"`
}

// Struct to represent the request body for creating a message
type MessageRequest struct {
	Message struct {
		Body string `json:"body"`
	} `json:"message"`
}

func main() {
	// Initialize Redis client
	rdb := redis.NewClient(&redis.Options{
		Addr: "redis:6400", // Assuming Redis is running on the container "redis:6400"
		DB:   0,            // Redis DB index
	})
	// Handle requests for chat and message creation
	http.HandleFunc("/apps/", func(w http.ResponseWriter, r *http.Request) {
		// Parse the URL path
		parts := strings.Split(r.URL.Path, "/")
		if len(parts) < 4 {
			http.Error(w, "Invalid URL path", http.StatusBadRequest)
			return
		}

		appToken := parts[2] // Extract app_token
		if len(parts) == 4 && parts[3] == "chats" && r.Method == http.MethodPost {
			// Handle chat creation
			handleChatCreation(w, r, rdb, appToken)
		} else if len(parts) == 6 && parts[3] == "chats" && parts[5] == "messages" && r.Method == http.MethodPost {
			// Handle message creation
			chatNumber := parts[4] // Extract chat_number
			handleMessageCreation(w, r, rdb, appToken, chatNumber)
		} else {
			http.Error(w, "Invalid URL path", http.StatusNotFound)
		}
	})

	// Start the server
	port := "8080" // Use your desired port
	log.Printf("Server started at http://localhost:%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// Handle chat creation
func handleChatCreation(w http.ResponseWriter, r *http.Request, rdb *redis.Client, appToken string) {
	// Use Redis atomic increment to get the chat_number
	redisKey := fmt.Sprintf("app:%s:chat_count", appToken)

	// Increment the chat_count atomically in Redis
	chatNumber, err := rdb.Incr(ctx, redisKey).Result()
	if err != nil {
		log.Printf("Failed to increment chat_number for app %s: %v", appToken, err)
		http.Error(w, "App not found", http.StatusInternalServerError)
		return
	}
	// Log the received request (in a real app, we'd process it)
	log.Printf("Received request to create chat for app_token: %s with chat_number: %d", appToken, chatNumber)

	// Set the message_count to 0 for the new chat (initialize it)
	messageCountKey := fmt.Sprintf("chat:%s:%d:message_count", appToken, chatNumber)
	err = rdb.Set(ctx, messageCountKey, 0, 0).Err() // 0 for default expiration time (persistent key)
	if err != nil {
		log.Printf("Failed to set message_count for chat %d: %v", chatNumber, err)
		http.Error(w, "Failed to initialize message_count", http.StatusInternalServerError)
		return
	}
	// Simulate the creation of a chat (e.g., saving it in Redis)
	chatData := map[string]interface{}{
		"class":       "ChatCreationJob",                   // Sidekiq worker class name
		"args":        []interface{}{appToken, chatNumber}, // Pass dynamic parameters here
		"queue":       "default",                           // Queue name
		"retry":       true,                                // Retry if it fails
		"jid":         "unique-job-id",                     // Unique Job ID
		"created_at":  time.Now().Unix(),
		"enqueued_at": time.Now().Unix(),
	}
	// Serialize the job to JSON
	jobJSON, err := json.Marshal(chatData)
	if err != nil {
		log.Fatalf("Failed to marshal job: %v", err)
	}

	// Push the job to the Redis queue
	queueKey := "queue:default" // The default queue for Sidekiq jobs
	err = rdb.LPush(ctx, queueKey, jobJSON).Err()
	if err != nil {
		log.Fatalf("Failed to push job to Redis: %v", err)
	}

	fmt.Printf("Job pushed successfully to Redis for Sidekiq with appToken: %s and chatNumber: %d\n", appToken, chatNumber)
	// Respond with a JSON containing the chat_number
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	response := map[string]interface{}{
		"chat_number": chatNumber,
	}
	json.NewEncoder(w).Encode(response)
}

// Handle message creation
func handleMessageCreation(w http.ResponseWriter, r *http.Request, rdb *redis.Client, appToken, chatNumber string) {
	// Use Redis atomic increment to get the message_count
	redisKey := fmt.Sprintf("chat:%s:%s:message_count", appToken, chatNumber)
	// print the redis key
	fmt.Println(redisKey)
	// Increment the message_count atomically in Redis
	messageNumber, err := rdb.Incr(ctx, redisKey).Result()
	if err != nil {
		log.Printf("Failed to increment chat_number for app %s: %v", appToken, err)
		http.Error(w, "App not found", http.StatusInternalServerError)
		return
	}
	// Log the received request (in a real app, we'd process it)
	log.Printf("Received request to create message for app_token: %s and with chat_number: %s with message_number %d", appToken, chatNumber, messageNumber)

	var messageReq MessageRequest                     // Struct to hold the incoming message body
	err = json.NewDecoder(r.Body).Decode(&messageReq) // Parse the JSON body
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	messageBody := messageReq.Message.Body // Extract the message body

	// Log the received request
	log.Printf("Received request to create message for app_token: %s, chat_number: %s, message_body: %s", appToken, chatNumber, messageBody)

	// Simulate the creation of a message (e.g., saving it in Redis)
	jobData := map[string]interface{}{
		"class":       "MessageCreationJob",                                            // Sidekiq worker class name
		"args":        []interface{}{appToken, chatNumber, messageNumber, messageBody}, // Pass parameters here
		"queue":       "default",                                                       // Queue name
		"retry":       true,                                                            // Retry if it fails
		"jid":         "unique-job-id",                                                 // Unique Job ID
		"created_at":  time.Now().Unix(),
		"enqueued_at": time.Now().Unix(),
	}

	// Serialize the job to JSON
	jobJSON, err := json.Marshal(jobData)
	if err != nil {
		log.Fatalf("Failed to marshal job: %v", err)
	}

	// Push the job to the Redis queue
	queueKey := "queue:default" // The default queue for Sidekiq jobs
	err = rdb.LPush(ctx, queueKey, jobJSON).Err()
	if err != nil {
		log.Fatalf("Failed to push job to Redis: %v", err)
	}

	// Respond with a success message
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	response := map[string]interface{}{
		"message_number": messageNumber,
	}
	json.NewEncoder(w).Encode(response)
}
