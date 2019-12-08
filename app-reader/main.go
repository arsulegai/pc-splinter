// Copyright 2019 Walmart Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"flag"
	"log"
	"os"
	"app-reader/lib"
	"gopkg.in/confluentinc/confluent-kafka-go.v1/kafka"
)

var APP_VERSION string
var APP_NAME string

var versionFlag *bool = flag.Bool(
	"v", false, "Print the version number.")
var kafka_server *string = flag.String(
	"kafka", "localhost:9092", "Kafka cluster endpoint")
var topic *string = flag.String(
	"topic", "splinter", "Topic to listen to")

// Initialize package name and version
func init() {
	if APP_VERSION == lib.EMPTY_STRING {
		APP_VERSION = "0.1"
	}
	if APP_NAME == lib.EMPTY_STRING {
		APP_NAME = "Application Reader"
	}
}

func main() {
	log.Printf("%s, Version: %s\n", APP_NAME, APP_VERSION)

	var errors []error
	var returnCode int
	returnCode = 0

	defer func() {
		if len(errors) != 0 {
			log.Printf("Error occurred: %v\n", errors)
		}
		os.Exit(returnCode)
	}()

	flag.Parse() // Scan the arguments list

	if *versionFlag {
		log.Println("Version:", APP_VERSION)
		return
	}
	c, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers": *kafka_server,
		"group.id":          "myGroup",
		"auto.offset.reset": "earliest",
	})

	if err != nil {
		returnCode = 1
		errors = append(errors, err)
		return
	}

	c.SubscribeTopics([]string{*topic}, nil)

	log.Println("Listening on ", *kafka_server, " for the topic ", *topic)

	for {
		msg, err := c.ReadMessage(-1)
		if err == nil {
			log.Printf("Message on %s: %s\n", msg.TopicPartition, string(msg.Value))
		} else {
			// The client will automatically try to recover from all errors.
			log.Printf("Consumer error: %v (%v)\n", err, msg)
		}
	}

	c.Close()
}
