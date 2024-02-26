package main

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/batch/types"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/batch"
)

func handler(ctx context.Context, s3Event events.S3Event) error {
	sdkConfig, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("failed to load default config: %s", err)
		return err
	}

	jobDefinition := "video-transcode-job-definition"
	jobName := "transcode-job"
	jobQueue := "HighPriorityTranscodeQueue"

	client := batch.NewFromConfig(sdkConfig)

	for _, record := range s3Event.Records {
		key := record.S3.Object.URLDecodedKey
		parts := strings.Split(key, "/")
		environments := []types.KeyValuePair{
			{
				Name:  aws.String("OBJECT_NAME"),
				Value: aws.String(parts[1]),
			},
		}
		input := &batch.SubmitJobInput{
			JobDefinition:              aws.String(jobDefinition),
			JobName:                    aws.String(jobName),
			JobQueue:                   aws.String(jobQueue),
			SchedulingPriorityOverride: aws.Int32(99),
			ShareIdentifier:            aws.String("A1"),
			ContainerOverrides: &types.ContainerOverrides{
				Environment: environments,
			},
		}
		output, err := client.SubmitJob(ctx, input)

		if err != nil {
			log.Printf("error submitting a job %s to queue %s with job definition %s and environments %v, err: %v", jobName, jobQueue, jobDefinition, environments, err)
			return err
		}

		log.Printf("successfully published job with response: %v", output)
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
